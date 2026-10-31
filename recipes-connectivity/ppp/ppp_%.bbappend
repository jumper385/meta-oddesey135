# netfailover controls DNS. Stop the ppp package from changing DNS each time the link comes up.
do_install:append() {
    rm -f ${D}${sysconfdir}/ppp/ip-up.d/08setupdns
    rm -f ${D}${sysconfdir}/ppp/ip-down.d/92removedns
}
