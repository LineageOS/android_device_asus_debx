#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
import common
import struct

def FindRadio(zipfile):
  try:
    return zipfile.read("RADIO/radio.img")
  except KeyError:
    return None


def FullOTA_InstallEnd(info):
  try:
    bootloader_img = info.input_zip.read("RADIO/bootloader.img")
  except KeyError:
    print "no bootloader.img in target_files; skipping install"
  else:
    WriteBootloader(info, bootloader_img)

  radio_img = FindRadio(info.input_zip)
  if radio_img:
    WriteRadio(info, radio_img)
  else:
    print "no radio.img in target_files; skipping install"

  DDR_img = FindDDR(info.input_zip)
  if DDR_img:
    WriteDDR(info, DDR_img)
  else:
    print "no DDR.bin in target_files; skipping install"


def IncrementalOTA_VerifyEnd(info):
  target_radio_img = FindRadio(info.target_zip)
  source_radio_img = FindRadio(info.source_zip)
  if not target_radio_img or not source_radio_img: return
  if source_radio_img != target_radio_img:
    info.script.CacheFreeSpaceCheck(len(source_radio_img))
    radio_type, radio_device = common.GetTypeAndDevice("/radio", info.info_dict)
    info.script.PatchCheck("%s:%s:%d:%s:%d:%s" % (
        radio_type, radio_device,
        len(source_radio_img), common.sha1(source_radio_img).hexdigest(),
        len(target_radio_img), common.sha1(target_radio_img).hexdigest()))


def IncrementalOTA_InstallBegin(info):
  # Reduce the space taken by the journal.
  info.script.Unmount("/system")
  info.script.TunePartition("/system", "-O", "^has_journal")
  info.script.Mount("/system")


def IncrementalOTA_InstallEnd(info):
  try:
    target_bootloader_img = info.target_zip.read("RADIO/bootloader.img")
    try:
      source_bootloader_img = info.source_zip.read("RADIO/bootloader.img")
    except KeyError:
      source_bootloader_img = None

    if source_bootloader_img == target_bootloader_img:
      print "bootloader unchanged; skipping"
    else:
      WriteBootloader(info, target_bootloader_img)
  except KeyError:
    print "no bootloader.img in target target_files; skipping install"

  df = FindDDR(info.target_zip)
  if not df:
    print "no DDR.bin in target target_files; skipping install"
  else:
    df = common.File("DDR.bin", df)
    WriteDDR(info, df.data)

  tf = FindRadio(info.target_zip)
  if not tf:
    # failed to read TARGET radio image: don't include any radio in update.
    print "no radio.img in target target_files; skipping install"
  else:
    tf = common.File("radio.img", tf)

    sf = FindRadio(info.source_zip)
    if not sf:
      # failed to read SOURCE radio image: include the whole target
      # radio image.
      WriteRadio(info, tf.data)
    else:
      sf = common.File("radio.img", sf)

      if tf.sha1 == sf.sha1:
        print "radio image unchanged; skipping"
      else:
        diff = common.Difference(tf, sf, diff_program="bsdiff")
        common.ComputeDifferences([diff])
        _, _, d = diff.GetPatch()
        if d is None or len(d) > tf.size * common.OPTIONS.patch_threshold:
          # computing difference failed, or difference is nearly as
          # big as the target:  simply send the target.
          WriteRadio(info, tf.data)
        else:
          common.ZipWriteStr(info.output_zip, "radio.img.p", d)
          info.script.Print("Patching radio...")
          radio_type, radio_device = common.GetTypeAndDevice(
              "/radio", info.info_dict)
          info.script.ApplyPatch(
              "%s:%s:%d:%s:%d:%s" % (radio_type, radio_device,
                                     sf.size, sf.sha1, tf.size, tf.sha1),
              "-", tf.size, tf.sha1, sf.sha1, "radio.img.p")


def WriteRadio(info, radio_img):
  info.script.Print("Writing radio...")
  common.ZipWriteStr(info.output_zip, "radio.img", radio_img)
  _, device = common.GetTypeAndDevice("/radio", info.info_dict)
  WriteImageAssert(info, "radio.img", radio_img, device)

def FindDDR(zipfile):
  try:
    return zipfile.read("RADIO/DDR.bin")
  except KeyError:
    return None


def WriteDDR(info, DDR_img):
  info.script.Print("Writing DDR...")
  common.ZipWriteStr(info.output_zip, "DDR.bin", DDR_img)
  info.script.AppendExtra(
      'package_extract_file("DDR.bin", "/dev/block/platform/msm_sdcc.1/by-name/DDR");' )

# /* msm8960 bootloader.img format */
#
# #define BOOTLDR_MAGIC "BOOTLDR!"
# #define BOOTLDR_MAGIC_SIZE 8
#
# struct bootloader_images_header {
#         char magic[BOOTLDR_MAGIC_SIZE];
#         unsigned int num_images;
#         unsigned int start_offset;
#         unsigned int bootldr_size;
#         struct {
#                 char name[64];
#                 unsigned int size;
#         } img_info[];
# };

def WriteBootloader(info, bootloader):
  info.script.Print("Writing bootloader...")

  # bootloader.img contains 6 separate images.  Each goes to its own
  # partition; we write all 6 for development devices but skip one for
  # release devices..  There are backup partitions of all but the
  # special one that we also write.  The special one is "sbl1", which
  # does not have a backup, so we don't update it on release devices..


  header_fmt = "<8sIII"
  header_size = struct.calcsize(header_fmt)
  magic, num_images, start_offset, bootloader_size = struct.unpack(
      header_fmt, bootloader[:header_size])
  assert magic == "BOOTLDR!", "bootloader.img bad magic value"

  img_info_fmt = "<64sI"
  img_info_size = struct.calcsize(img_info_fmt)

  imgs = [struct.unpack(img_info_fmt,
                        bootloader[header_size+i*img_info_size:
                                     header_size+(i+1)*img_info_size])
          for i in range(num_images)]

  total = 0
  p = start_offset
  img_dict = {}
  for name, size in imgs:
    img_dict[trunc_to_null(name)] = p, size
    p += size
  assert p - start_offset == bootloader_size, "bootloader.img corrupted"
  imgs = img_dict

  common.ZipWriteStr(info.output_zip, "bootloader-flag.txt",
                     "updating-bootloader" + "\0" * 13)
  common.ZipWriteStr(info.output_zip, "bootloader-flag-clear.txt", "\0" * 32)

  _, misc_device = common.GetTypeAndDevice("/misc", info.info_dict)

  info.script.AppendExtra(
      'package_extract_file("bootloader-flag.txt", "%s");' %
      (misc_device,))

  # flashing sbl1 is somewhat dangerous because if we die while doing
  # it the device can't boot.  Do it for development devices but not
  # release devices.
  fp = info.info_dict["build.prop"]["ro.build.fingerprint"]
  if "release-keys" in fp:
    to_flash = "sbl2 sbl3 tz rpm aboot".split()
  else:
    to_flash = "sbl1 sbl2 sbl3 tz rpm aboot".split()

  # Write the images to separate files in the OTA package
  for i in to_flash:
    try:
      _, device = common.GetTypeAndDevice("/"+i, info.info_dict)
    except KeyError:
      print "skipping flash of %s; not in recovery.fstab" % (i,)
      continue
    common.ZipWriteStr(info.output_zip, "bootloader.%s.img" % (i,),
                       bootloader[imgs[i][0]:imgs[i][0]+imgs[i][1]])

    WriteImageAssert(info, "bootloader.%s.img" % (i,),
            bootloader[imgs[i][0]:imgs[i][0]+imgs[i][1]], device)

  info.script.AppendExtra(
      'package_extract_file("bootloader-flag-clear.txt", "%s");' %
      (misc_device,))

  try:
    # there is no "sbl1b" partition
    for i in "sbl2 sbl3 tz rpm aboot".split():
      _, device = common.GetTypeAndDevice("/"+i+"b", info.info_dict)
      WriteImageAssert(info, "bootloader.%s.img" % (i,),
              bootloader[imgs[i][0]:imgs[i][0]+imgs[i][1]], device)
  except KeyError:
    pass


def trunc_to_null(s):
  if '\0' in s:
    return s[:s.index('\0')]
  else:
    return s


def WriteImageAssert(info, file_name, file_data, partition):
  checksum = common.sha1(file_data).hexdigest()
  file_size = len(file_data)
  info.script.AppendExtra('ifelse((sha1_check(read_file("EMMC:%s:%d:%s")) != ""),'
          '(ui_print("%s already up to date")),'
          '(package_extract_file("%s", "%s")));'
          % (partition, file_size, checksum, partition, file_name, partition))
