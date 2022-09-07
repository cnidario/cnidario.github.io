---
title: Unbricking a TP-LINK Router (TL-WR841N)
author: cnidario
date: 2022-09-07
---

I like very much this old router and I'd rather prefer to use it than the brand new one that came with the ISP company. 

Reasons to love the TL-WR841N include:
- It does the job fairly well (well, sometimes it struggles to manage a lot of traffic, but it usually works well).
- It can be flashed with a [DD-WRT](dd-wrt.com) firmware. 
- It is small and low power while doing all the things I need. It has a nominal power of 5.4W while in my new Zyxel VMG8924 is 24W! more than 4 times. 
Unfortunately, when trying to update my custom DD-WRT I've bricked it and became unbootable.

## How to unbrick
Usually, the last and only resort to save the life of these devices used to be opening the case and plug some sort of USB to UART/JTAG/... in a special socket in the PCB and to the computer and reflash the original stock firmware.

**But** this TL-WR841N has an amazing new feature, the bootloader comes with a fallback mechanism and we only need to mount a TFTP server.

## Steps

This instructions are almost the same for this model versions v8, v9, v10, v11 and v12. Just change vXX in the name of the firmware file. **Be sure to download the specific version file though!!**

1. Download the latest official version from the TP-LINK [page](www.tp-link.com/es/support/download/tl-wr841n/v11/#Firmware). Looking the stick at the back of the router I can see the the exact model and version, in my case v11.1.
2. Unzip and rename the .bin to wr841nv11_tp_recovery.bin (in my case, check the [OpenWRT wiki](https://oldwiki.archive.openwrt.org/toh/tp-link/tl-wr841nd#tftp_recovery_via_bootloader_for_v8_v9_v10_v11_v12) to the details)
3. Setup the TFTP server
```{.console}
 # pacman -S tftp-hpa
 ##### then I removed the '--secure' part of /etc/conf.d/tftpd but maybe it is not necessary 
 # systemctl start tftpd
 # cp wr841nv11_tp_recovery.bin /srv/tftp
 ##### check with curl
 $ curl -o tmp-test-file-remove tftp://localhost/wr841nv11_tp_recovery.bin
```
4. Set the ethernet network. Static IP.
```{.console}
#### The TFTP server will be looked in 192.168.0.66/24 and the router will be 192.168.0.86
# ip addr add 192.168.0.66/24 broadcast + dev enp0sxxxx # enp0s is your network device
```
5. Conect the cable from the pc to the router (I've used the WAN port, the blue one)
6. Power on the router while pressing the reset until the lock LED light is on.
7. Wait till the router reboot.

Finally you can connect to the Wifi of the router with the factory credentials 8).
