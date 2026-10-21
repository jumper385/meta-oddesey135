# meta-oddesey — ODYSSEY-STM32MP135D

Tested with OpenSTLinux openstlinux-6.6-yocto-scarthgap-mpu-v25.06.11.

```
mkdir stm32mp1-ostl && cd stm32mp1-ostl
repo init -u https://github.com/STMicroelectronics/oe-manifest.git -b refs/tags/openstlinux-6.6-yocto-scarthgap-mpu-v25.06.11
repo sync
git clone <YOUR-REPO-URL> layers/meta-oddesey
DISTRO=openstlinux-weston MACHINE=stm32mp13-mx source layers/meta-st/scripts/envsetup.sh
bitbake-layers add-layer ../layers/meta-oddesey
bitbake-layers add-layer ../layers/meta-st/meta-st-stm32mp-addons
echo 'require conf/oddesey.conf' >> conf/local.conf
bitbake core-image-minimal
```

After editing anything under mx/, run:
```
bitbake -c cleansstate tf-a-stm32mp optee-os-stm32mp u-boot-stm32mp fip-stm32mp linux-stm32mp st-image-bootfs
```

Once that builds, you will need to manually build the SD Card Image
```
cd tmp-glibc/deploy/images/stm32mp13-mx
rm -f FlashLayout_sdcard_stm32mp135d-oddesey-mx-optee.raw*
SDCARD_SIZE=1024 ./scripts/create_sdcard_from_flashlayout.sh --force-rootfs --compress flashlayout_core-image-minimal/optee/FlashLayout_sdcard_stm32mp135d-oddesey-mx-optee.tsv
```
