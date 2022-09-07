---
title: Installing OpenWrt in a TP-LINK TL-WR841N Router
author: cnidario
date: 2022-09-07
---

This is an old router but I like to use old technology that works. Low power, low specs, minimalism, battle-tested, no bloat.

## Getting the image
At the time of speaking, 2022, OpenWrt already had dropped support years ago for this model because its low RAM and Flash memory.
Anyway there is an old one that works. It's [here](https://oldwiki.archive.openwrt.org/toh/tp-link/tl-wr841nd#installation)

## Setting the TFTP server
For some reason I can't flash my own firmware through the web interface so I've used the TFTP method, allegedly there is some regional codes in the formware binary that are checked in the web interface but not in the TFTP recovery method.
```{.console}
# pacman -S tftp-hpa
### edit /etc/conf.d/tftpd and prepend -v -v -v to the options, I've used this for debugguing purposes to see the router accessing my server
# systemctl start tftpd
### check logs with
# journalctl --unit tftpd
### copy the file. The name must be the same that the one for recovery, in this case (my router version is 11.1) wr841nv11_tp_recovery.bin
# cp PLACEHOLDER /srv/tftp/wr841nv11_tp_recovery.bin
```

## Set the network
```{.console}
# ip addr add 192.168.0.66/24 dev enp0sxxx
```
Plug the ethernet cable to the WAN port of the router and to your computer. Then power on the router while pressing the reset button until the lock LED lights up. Then wait for the router to reboot.

## Configuring

At first, Wifi is disabled and you have to access through SSH. Reconnect the ethernet cable but this time to any other non-WAN port. We need now to get our IP by DHCP.
```{.console}
# ip addr del 192.168.0.66/24 dev enp0sxxx
# dhclient enp0sxxxx -v
### modern versions of SSH have been disabled insecure and old algorithms, so we have to explicitly enable it now
# ssh -oHostKeyAlgorithms=+ssh-rsa root@192.168.1.1
```
![](img/openwrt-tl-wr841n-1.png "Voilà, we're in")

**Important step!** Remember to change the SSH empty root password with `passwd`. 

## Setting the wifi
OpenWrt uses the [UCI](https://openwrt.org/docs/guide-user/base-system/uci) configuration system.
```{.console}
# uci show wireless ## show current wireless options
# uci set wireless.radio0.country='EU' ## country code
# uci set wireless.radio0.disabled='0' ## enable wireless
# uci set wireless.@wifi-iface[0].ssid='YOUR WIFI NETWORK NAME'
# uci set wireless.@wifi-iface[0].encryption='psk+tkip+ccmp' ## CCMP is more secure, the others are for maximum compatibility
# uci set wireless.@wifi-iface[0].key='YOUT NETWORK PASSWORD' ## Wifi password in **plain** format
# uci commit wireless ## commit changes
# wifi reload ## reload the wifi system
```
