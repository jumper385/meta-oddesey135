#!/bin/sh
# Create a USB CDC-ACM gadget with configfs. The host PC sees a serial port
# (/dev/ttyACM0 on Linux, COMx on Windows). systemd starts a getty on ttyGS0.
set -e

G=/sys/kernel/config/usb_gadget/g1

modprobe libcomposite 2>/dev/null || true
modprobe usb_f_acm 2>/dev/null || true

# Already set up (service restarted)
[ -e "$G/UDC" ] && [ -n "$(cat "$G/UDC")" ] && exit 0

# The OTG port uses a role switch (no VBUS sensing on this board): select device role
for r in /sys/class/usb_role/*/role; do
    [ -w "$r" ] && echo device > "$r" || true
done

# Wait up to 10 s for the USB device controller
i=0
while [ -z "$(ls /sys/class/udc 2>/dev/null)" ]; do
    i=$((i + 1))
    [ $i -gt 100 ] && { echo "usb-gadget-acm: no UDC found" >&2; exit 1; }
    sleep 0.1
done
UDC=$(ls /sys/class/udc | head -n 1)

SERIAL=$(tr -d '\0' 2>/dev/null < /proc/device-tree/serial-number || echo 0123456789)

mkdir -p "$G"
echo 0x1d6b > "$G/idVendor"     # Linux Foundation
echo 0x0104 > "$G/idProduct"    # Multifunction Composite Gadget
echo 0x0100 > "$G/bcdDevice"
echo 0x0200 > "$G/bcdUSB"

mkdir -p "$G/strings/0x409"
echo "$SERIAL"                 > "$G/strings/0x409/serialnumber"
echo "Odyssey"                 > "$G/strings/0x409/manufacturer"
echo "STM32MP135 USB console"  > "$G/strings/0x409/product"

mkdir -p "$G/configs/c.1/strings/0x409"
echo "CDC ACM" > "$G/configs/c.1/strings/0x409/configuration"
echo 250       > "$G/configs/c.1/MaxPower"

mkdir -p "$G/functions/acm.GS0"
[ -e "$G/configs/c.1/acm.GS0" ] || ln -s "$G/functions/acm.GS0" "$G/configs/c.1/"

echo "$UDC" > "$G/UDC"
echo "usb-gadget-acm: ACM gadget bound to $UDC (/dev/ttyGS0)"
