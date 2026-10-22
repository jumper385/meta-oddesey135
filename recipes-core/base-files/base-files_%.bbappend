do_install:append() {
    echo "/dev/disk/by-partlabel/userfs  /usr/local  ext4  defaults,nofail  0  2" >> ${D}${sysconfdir}/fstab
}
