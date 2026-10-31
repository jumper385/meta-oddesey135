SUMMARY = "nRF93M1 LTE PPP link with Ethernet-first fallback"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://nrf93m1 \
           file://nrf93m1.chat \
           file://99-nrf93m1.rules \
           file://nrf93m1-ppp.service \
           file://50-nrf93m1-dns \
           file://netfailover.sh \
           file://netfailover.service \
          "
S = "${WORKDIR}"

inherit systemd
SYSTEMD_SERVICE:${PN} = "nrf93m1-ppp.service netfailover.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${sysconfdir}/ppp/peers ${D}${sysconfdir}/chatscripts \
               ${D}${sysconfdir}/ppp/ip-up.d ${D}${sysconfdir}/udev/rules.d \
               ${D}${sbindir} ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/nrf93m1             ${D}${sysconfdir}/ppp/peers/nrf93m1
    install -m 0644 ${S}/nrf93m1.chat        ${D}${sysconfdir}/chatscripts/nrf93m1
    install -m 0755 ${S}/50-nrf93m1-dns      ${D}${sysconfdir}/ppp/ip-up.d/50-nrf93m1-dns
    install -m 0644 ${S}/99-nrf93m1.rules    ${D}${sysconfdir}/udev/rules.d/99-nrf93m1.rules
    install -m 0755 ${S}/netfailover.sh      ${D}${sbindir}/netfailover.sh
    install -m 0644 ${S}/nrf93m1-ppp.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/netfailover.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}"
RDEPENDS:${PN} = "ppp iputils-ping"
