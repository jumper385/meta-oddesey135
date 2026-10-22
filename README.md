```
mkdir stm32mp1-ostl && cd stm32mp1-ostl
repo init -u https://github.com/STMicroelectronics/oe-manifest.git -b refs/tags/openstlinux-6.6-yocto-scarthgap-mpu-v25.06.11
repo sync
git clone https://github.com/jumper385/meta-oddesey135 layers/meta-oddesey
git clone https://github.com/rauc/meta-rauc layers/meta-rauc
git -C layers/meta-rauc checkout d63878f20eba7a85ecf53566e7a3377e78bb46ac

# Copy the openssl-ca folder from your backup to stm32mp1-ostl/openssl-ca

DISTRO=openstlinux-weston MACHINE=stm32mp13-mx source layers/meta-st/scripts/envsetup.sh
bitbake-layers add-layer ../layers/meta-st/meta-st-stm32mp-addons
bitbake-layers add-layer ../layers/meta-rauc
bitbake-layers add-layer ../layers/meta-oddesey
cat ../layers/meta-oddesey/conf/local.conf.append >> conf/local.conf
bitbake core-image-minimal oddesey-bundle
```

SD card (A/B layout):
```
cd tmp-glibc/deploy/images/stm32mp13-mx
cp ../../../../../layers/meta-oddesey/flashlayout/FlashLayout_sdcard_oddesey-ab.tsv flashlayout_core-image-minimal/optee/
SDCARD_SIZE=4096 ./scripts/create_sdcard_from_flashlayout.sh --force-rootfs --compress flashlayout_core-image-minimal/optee/FlashLayout_sdcard_oddesey-ab.tsv
```

Update:
```
scp oddesey-bundle-stm32mp13-mx.raucb root@<board-ip>:/usr/local/
rauc install /usr/local/oddesey-bundle-stm32mp13-mx.raucb && reboot
rauc status mark-good
```
