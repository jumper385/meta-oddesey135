test -n "${BOOT_ORDER}"  || setenv BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || setenv BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || setenv BOOT_B_LEFT 3

setenv rauc_slot
for s in ${BOOT_ORDER}; do
  if test "x${rauc_slot}" = "x"; then
    if test "x${s}" = "xA" && test ${BOOT_A_LEFT} -gt 0; then
      setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
      setenv rauc_slot A
    elif test "x${s}" = "xB" && test ${BOOT_B_LEFT} -gt 0; then
      setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
      setenv rauc_slot B
    fi
  fi
done

if test "x${rauc_slot}" = "x"; then
  echo "No good slot. Reset counters."
  setenv BOOT_A_LEFT 3
  setenv BOOT_B_LEFT 3
  saveenv
  reset
fi
saveenv

echo "Boot slot ${rauc_slot}"
setenv bootargs "root=PARTLABEL=rootfs${rauc_slot} rootwait rw console=${console},${baudrate} rauc.slot=${rauc_slot}"
load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} /uImage
load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} /stm32mp135d-oddesey-mx.dtb
bootm ${kernel_addr_r} - ${fdt_addr_r}
