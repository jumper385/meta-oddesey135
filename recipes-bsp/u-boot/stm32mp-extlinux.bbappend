FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://boot-ab.cmd"
UBOOT_EXTLINUX_BOOTSCR = "${WORKDIR}/boot-ab.cmd"

# Always build the A/B script. Do not install extlinux.conf.
do_compile() {
    mkimage -C none -A ${UBOOT_ARCH} -T script -d ${UBOOT_EXTLINUX_BOOTSCR} ${UBOOT_EXTLINUX_BOOTSCR_IMG}
}

do_install() {
    install -d ${D}/${UBOOT_EXTLINUX_INSTALL_DIR}
    install -m 755 ${UBOOT_EXTLINUX_BOOTSCR_IMG} ${D}/${UBOOT_EXTLINUX_INSTALL_DIR}
}
