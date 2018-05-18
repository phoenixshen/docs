#flash优化方案介绍

TAG: openwrt linux memory

---
[toc]

##Open Issue

- 如何保证在flash过小的情况下，不会出现由于剩余空间耗尽导致系统程序无法启动。
调研出现空间耗尽对系统的影响。

- 如何保证和正常版本镜像在烧录出错的情况下，uboot仍然可以正常启动

- 集成PCBA测试工具
- 集成wifi ATE 测试工具
- 发布合入网页OTA升级（简化）功能版本

##flash优化方案介绍

###原flash使用情况
- 分区划分

| 分区名        | 大小   |
| --------   | -----:  |
| UBOOT SPL| 128K|  
| UBOOT        |   384K   |
| UBOOT ENV |    64K   |
| FACTORY|    64K   |
|SYSTEM|   15744K|
|SUM|   16384K|

- 镜像大小

| 分区       | 镜像| 大小   |
| --------   | ------- |-----:  |
| UBOOT SPL| u-boot-spl.img|  62K|
| UBOOT |    u-boot.img   | 319K|
|FIRMWARE | openwrt-siflower-sf16a18-mpw0-squashfs-sysupgrade.bin |8650K|


###优化后flash使用情况
 - 分区划分

| 分区名        | 大小   |
| --------   | -----:  |
| UBOOT SPL| 32K|  
| UBOOT        |   164K    |
| FACTORY|    4K   |
|SYSTEM|   3896K|
|SUM|   4096K|


 - 镜像大小

| 分区       | 镜像| 大小   |
| --------   | ------- |-----:  |
| UBOOT SPL| u-boot-spl.img|  32K|
| UBOOT |    u-boot.img   | 164K|
|FIRMWARE | openwrt-siflower-sf16a18-mpw0-squashfs-sysupgrade.bin |3329K|      

系统启动后，仍有800K左右的free space 可以使用。

Uboot spl uboot 以及组成系统的kernel 和openwrt rootfs 文件系统都进行了优化，整体占用空间
只有之前总体大小的的39%。

##编译及使用

###编译

- 编译 UBOOT flash 优化镜像
    在uboot目录， 使用./make.sh p10flash

- 编译 OpenWrt flash 优化镜像
    在OpenWRT目录，使用./make.sh p10flash


###烧录

- 烧录UBOOT
    通过uboot界面烧录 uboot镜像

- 烧录OpenWRT
    通过uboot界面烧录 OpenWRT镜像

-- 参见SF16A18开发入门指南

注意：使用master版本镜像的路由，必须先烧录UBOOT，然后烧录OpenWRT镜像，否则会导致系统无法启动。


##优化功能

 - 概述

| 模块       | 优化方法 |
| ------ | ------ |
| WiFi lmac | 代码优化，2.4g 5g firmware 合并 |
| Wifi Umac | 代码优化，debug fs移除，2.4g 5g ko 合并 |
| OpenWrt 系统 | 编译生成镜像前删除不必要文件,配置文件中移除非必要模块 |
| LuCI 优化 | 编译控制使用裁剪过的LuCI package|
| 内核优化| 驱动代码优化，编译配置文件中移除非必须模块|
| Uboot 优化| 代码优化，编译配置文件中移除非必须模块|


###裁剪模块
| 模块       | 所在位置 |  模块描述 |
| ------ | ------ | ------ |
| EMMC/SD |Uboot| 移除用不到的存储驱动|
| DMA |Uboot| 移除用不到的DMA驱动|
| SAVEENV 等ENV相关命令 |Uboot| 移除用不到的命令 |
| DHCP PING |Uboot| 移除用不到的网络命令|
| BOOTD GO RUN ECHO UPDATE 等命令|Uboot| 移除用不到的命令|
| GDMA | Linux | 移除不必要驱动|
| PWM| Linux | 移除不必要驱动|
| Curl| OpenWRT| 移除非必要模块|
|iperf| OpenWrt|移除非必要模块 |
|ipset| OpenWrt|移除非必要模块 |
|ndscan| OpenWrt|移除非必要模块 |
|ssh相关| OpenWrt|移除非必要模块 |
|tc| OpenWrt|移除非必要模块 |
|tcpdump| OpenWrt|移除非必要模块 |
|ssst相关| OpenWrt|移除非必要模块 |
|rwnxtools| OpenWrt|移除非必要模块 |
|debug fs| OpenWrt|移除非必要模块 |
|swap| OpenWrt|移除非必要模块 |
|debug kernel| OpenWrt|移除非必要模块 |
|coredump| OpenWrt|移除非必要模块 |
|ipv6| OpenWrt|移除非必要模块 |
|libpthread| OpenWrt|移除非必要模块 |
|librt| OpenWrt|移除非必要模块 |
|libstdcpp| OpenWrt|移除非必要模块 |
|opkg| OpenWrt|移除非必要模块 |
|mesh| OpenWrt|移除非必要模块 |
|px5g| OpenWrt|移除非必要模块 |
|PM | Linux|移除非必要模块 |
|SCSI| Linux|移除非必要模块 |
|MD| Linux|移除非必要模块 |
|HID| Linux|移除非必要模块 |
|DMA| Linux|移除非必要模块 |

###优化模块
| 模块       | 所在位置 | 模块描述 |
| ------ | ------ | ------ |
| spi | Uboot | 优化SPI代码，增肌 SFAX8_SPI_DYNAMIC_SETUP |
| timer | Uboot | 优化timer驱动代码 |
| UART | Uboot | 增加uart 驱动 |
| Uboot ENV | Uboot |  移除ENV 分区相关代码，移除ENV分区 |
| Pinctrl |Uboot | Pinctrl 代码优化，合并不同芯片版本的驱动 |
| Net|Uboot| 移除 404 和art 升级页面,错误直接跳转error界面 ,移除TFTP和BOOTP协议模块|
| Wifi Lmac| wireless-sw-sfax8| merge 2.4g/5g binary|
| Wifi Umac| OpenWRT| merge 2.4g/5g ko|
| LuCI| OpenWRT | 增加裁剪版本LuCI, 移除非必须要界面，以及SIROUTER相关功能|
| Busybox | OpenWRT | 移除Busybox中不需要的命令，vi telent等|
| PWRMGMT | Linux | 优化代码 |
| Pinctrl | Linux| Pinctrl 代码优化|
| NPU  | Linux| NPU代码优化|
| MTD | Linux && OpenWrt | 支持flash在地址非对齐状态快速烧录|
| OpenWRT| OpenWRT| 对于flash 优化进行特别的编译设计 |
| Wpadmini| OpenWRT| 切换wifi控制程序到mini版本|
