inherit bundle

RAUC_BUNDLE_COMPATIBLE = "oddesey-stm32mp135"
RAUC_BUNDLE_VERSION = "1.0"
RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "core-image-minimal"
RAUC_SLOT_rootfs[fstype] = "ext4"
RAUC_SLOT_rootfs[file] = "core-image-minimal-${DISTRO}-${MACHINE}.rootfs.ext4"
