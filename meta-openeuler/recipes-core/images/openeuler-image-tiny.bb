# no host package for image-tiny
TOOLCHAIN_HOST_TASK = ""

SUMMARY = "A small image just capable of allowing a device to boot."

# Note IMAGE_FSTYPES defination should before openeuler-image-common.inc(before inherit core-iamge/image.bbclass)
IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "262144"
#delete depends to cpio-native, use nativesdk's cpio
do_image_cpio[depends] = ""

require recipes-core/images/${MACHINE}.inc
require openeuler-image-common.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
"

# make no login
set_permissions_from_rootfs_append() {
   sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
}