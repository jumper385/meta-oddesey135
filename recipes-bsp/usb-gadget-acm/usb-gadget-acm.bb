SUMMARY = "Serial console (USB CDC-ACM gadget) on the USB-C port"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://usb-gadget-acm.sh \
           file://usb-gadget-acm.service \
          "

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "usb-gadget-acm.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${sbindir} ${D}${systemd_system_unitdir}
    install -m 0755 ${S}/usb-gadget-acm.sh ${D}${sbindir}/usb-gadget-acm.sh
    install -m 0644 ${S}/usb-gadget-acm.service ${D}${systemd_system_unitdir}/usb-gadget-acm.service
}

FILES:${PN} += "${systemd_system_unitdir}/usb-gadget-acm.service"

# Recommended, not required: a module that is built into the kernel has no package
RRECOMMENDS:${PN} += " \
    kernel-module-libcomposite \
    kernel-module-u-serial \
    kernel-module-usb-f-acm \
    kernel-module-dwc2 \
"
