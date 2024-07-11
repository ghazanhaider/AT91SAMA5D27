modprobe libcomposite
  cd /sys/kernel/config/usb_gadget
  mkdir g1
  cd g1
  echo "0x04D8" > idVendor
  echo "0x1234" > idProduct
  mkdir strings/0x409
  echo "0123456789" > strings/0x409/serialnumber
  echo "Ghazans USB gadget" > strings/0x409/manufacturer
  echo "Ghazans USB Gadget" > strings/0x409/product
  mkdir functions/ecm.usb0
  mkdir functions/acm.usb0
  mkdir configs/c.1
  mkdir configs/c.1/strings/0x409
  echo "CDC ACM+ECM" > configs/c.1/strings/0x409/configuration
  ln -s functions/ecm.usb0 configs/c.1
  ln -s functions/acm.usb0 configs/c.1
  echo "300000.gadget" > UDC

sleep 3
/sbin/ifconfig usb0 up
/sbin/udhcpc -i usb0 -b
