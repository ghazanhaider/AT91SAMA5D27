# AT91SAMA5D27

These are config files and steps to run buildroot/Linux on my custom SAMA5D27C board.
What works for me:
- A DDR3L memory chip that is run at DLL-off specs (124MHz bus speed) and 166MHz bus
- HDLCD with backlight (LCDPWM work in progress)
- USB Gadget with ACM+ECM (I can connect to console AND get Internet through my desktop)
- NAND + PMECC ECC and UBI/UBIFS without errors
- JTAG OR SWD + Vcom UART through the MIPI connector (requires J-Link with VCom)
- Latest Linux kernel, latest buildroot
- Passes memtester/fio/dmatest benchmarks on multiple boards

Whats broken:
- LCD has Blue and Red swapped
- UARTs are not electrically isolated, sam-ba writes sometime fails with UARTS connected to FTDI host


## Steps to build

(I will improve on these with proper defconfigs)

- Git clone buildroot
- Do any initial config `make O=/sama5d2 nconfig` and save
- Overwrite the resulting .config file under /sama5d2 with br_config
- `make O=/sama5d2 at91bootstrap3-menuconfig` and save
- Patch the files with patch-TODO if you're also using D2516ECMDXGJD-U DDR3 memory. Else use the patched lines as a template to add your own memory if it is not in the golden list.
- `make O=/sama5d2 uboot-nconfig` and save
- Overwrite its .config with uboot_config
- Do the same with Linux
- `make O=/sama5d2 all`
- Copy over boot.bin, ghazan-sama5d27.dtb, rootfs.ubi, u-boot.bin, uImage to a machine with sam-ba 3.8 installed
- Connect a usb-c cable to USB-A port with the BOOT jumper off. Put on the jumper once power light is on
- Sam-ba commands that worked for me, please adjust your directories:
```
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:1:1 -a nandflash:1:8:0xC2605007 -c erase::
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:0:1 -a nandflash:1:8:0xC2605007 -c writeboot:boot.bin
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:0:1 -a nandflash:1:8:0xC2605007 -c write:u-boot.bin:0x80000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:0:1 -a nandflash:1:8:0xC2605007 -c write:ghazan-sama5d27.dtb:0x180000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:1:1 -a nandflash:1:8:0xC2605007 -c write:uImage:0x1c0000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:1:1 -a nandflash:1:8:0xC2605007 -c write:rootfs.ubi:0x800000
```
- Connect a serial cable to the UART1 pins by the SWD port and open a terminal emulator
- Press reset to reset the board
- It SHOULD boot into Linux, the default bootarg works for me.


## Gadget fun

To enable USB Gadget serial + ECM Ethernet (works on MACOS without added drivers), follow these steps
- Mount UBI rw: `mount -o remount,rw /`
- Add a line to /etc/fstab to automatically mount configfs:
`none            /sys/kernel/config      configfs        rw      0       0`
- Put the following script in a file on the device:
```
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
```
- In my case this was /etc/gadget/sh
- Add a line in inittab to serve logins over the USB serial:
`ttyGS0::askfirst:/sbin/getty -L  ttyGS0 115200 xterm-256color`
- Add two lines in /etc/init.d/rcS to run gadget.sh:
```
modprobe libcomposite

/bin/sh /etc/gadget.sh
```
