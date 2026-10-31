FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://rauc.config file://usb-serial-modem.config"
KERNEL_CONFIG_FRAGMENTS:append = " ${WORKDIR}/rauc.config ${WORKDIR}/usb-serial-modem.config"
