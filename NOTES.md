# Various notes on my board


Good bootargs
`env set bootargs "console=ttyS1,115200 rootfstype=ubifs root=ubi0:rootfs ubi.mtd=5 video=Unknown-1:480x272-16 atmel-nand-controller.avoiddma=1"`

Storage benchmarks
`fio -filename=test -iodepth 1 -thread -rw=write -ioengine=libaio -bs=4k -size=64m -numjobs=1 -group_reporting -name=test`


## NAND partition layout

AT91Bootstrap3:		0x0		0x40000
U-Boot:			0x80000		0xC0000		# 0x40000 had errors on one of my boards
Env:			0x140000	0x40000		# Can be empty on first boot, overwrite with env to override defaults
DTB:			0x180000	0x40000		
uImage:			0x1C0000	0x640000	# I keep bumping into this limit unless I use slow XZ compression
Root.fs:		0x800000	0x1f0000000	# Leaving a few blocks at the end for BBT


## PMECC Header

```
eccOffset: 152 (0x98, shifted it is 0x260)
sectorSize/Size of ECC Sector: 0 (512)
eccBitReq: 2 (8bit ECC)
spareSizeinBytes: 256 (256 bytes)
sectorsPerPage: 3: (8 sectors per page)
PMECC: 1

= 0xC2605007
```


## DDR3L timings:
```
D1216ECMDXGJD-U
2k page size
16Mwords x 16bits x 8banks
Row address: A0 - A13
Column Address: A0 to A9

TIMINGS:
nRP = 13
nRRD = 6
tREFI = 7.8us

DATASHEET for 1833 (1.071 tCK):
tRAS Active to Precharge Delay: 32+ (JEDEC 38)
tRCD Row to column delay: 13+  (JEDEC 13)
tWR Write Recovery Delay: ? (JEDEC 15)
tRC Row Cycle Delay: 45+ (JEDEC 50)
tRP Row Precharge Delay: 13+ (JEDEC 13)
tRRD Active Bank1 to Active Bank2: 6 (JEDEC 10)
tWTR Internal Write to Read Delay: ?
tMRD Load MR cmd to Activate cmd:  (JEDEC 4)
tRFC Row Cycle Delay: 150
tTXSNR Exit Self Refresh delay: 
tTXSRD Exit Self Refresh delay: 
tTXP Exit pwr down delay to first cmd: 
tTRPA Row Precharge All Delay:
tTRTP Read to Precharge
tTFAW Four Active Windows : 33
RTC Refresh Timer Counter

RECALC above for 124MHz/8.06 ns (x 1.071 / 8.065 = 0.1328):
tRAS Active to Precharge Delay: 5+ (JEDEC 38) (0-15 allowed)
tRCD Row to column delay: 2+  (JEDEC 13) (0-15 allowed)
tWR Write Recovery Delay: ? (JEDEC 15) (1-15 allowed)
tRC Row Cycle Delay: 6+ (JEDEC 50) (0-15 allowed)
tRP Row Precharge Delay: 2+ (JEDEC 13) (0-15 allowed)
tRRD Active Bank1 to Active Bank2: 1 (JEDEC 10) (1-15 allowed)
tRFC Row Cycle Delay: 20 (0-127 allowed)
tMRD Load MR cmd to Activate cmd:  (JEDEC 4) (0-15 allowed)
tWTR Internal Write to Read Delay: ? (1-7 allowed)
tTXSNR Exit Self Refresh delay: same as tXS? (0-255 allowed)
tTXSRD Exit Self Refresh delay: 0 for DLL off
tTXP Exit pwr down delay to first cmd: (0-15 allowed)
tTRPA Row Precharge All Delay: DDR2 only
tTRTP Read to Precharge: (0-7 allowed)
tTFAW Four Active Windows : 5 (0-15 allowed)
RTC Refresh Timer Counter (3.9us): 483 (0x1e3)
TZQIO@124MHz in 600ns: 75 (0-127 allowed)

CAS MUST be set to 5
SHIFT_SAMPLING MUST be set to 2 in MPDDRC_RD_DATA_PATH (0x5c)
ZQCS calibration delay 0-255 clocks in MPDDRC_LPDDR2_LPDDR3_DDR3_TIM_CAL (0x30)
Output impedance 3 or 4 in RDIV in reg MPDDRC_IO_CALIBR (0x34)
Disable off chip scrambling MPDDRC_OCMS



Other notes:
EXAMPLE (CONFIG_DDR_MT41K128M16_D2@114MHz)
		.tras = 5,
        .trcd = 2,
        .twr = 4,
        .trc = 6,
        .trp = 2,
        .trrd = 4,
        .twtr = 4,
        .tmrd = 4,
        .trfc = 19,
        .txsnr = 21,
        .txsrd = 0,
        .txp = 10,
        .txard = 0,
        .txards = 0,
        .trpa = 0,
        .trtp = 4,
        .tfaw = 5,

but JEDEC for 800MHz is:
        .tras = 38,
        .trcd = 13,
        .trp = 13,
        .trc = 50,
        .twtr = 8,
        .trrd = 10,
        .twr = 15,
        .tmrd = 4,


From D1216 datasheet for 1833MHz speed bin:
CL = 13ns min
TRCD = 13ns min
TRP = 13ns min
TRAS = 34ns min (9x tREFI max)
TCK@CL6 = (given CWL=5, 303MHz to 400MHz)

TAA = 13.91 to 20ns 
TRC = 47.91ns min
```

