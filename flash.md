#flash优化计划

TAG: openwrt linux memory

---
[toc]

##现有情况


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
| UBOOT SPL| u-boot-spl.img|  62090|
| UBOOT |    u-boot.img   | 319883|
|FIRMWARE | openwrt-siflower-sf16a18-mpw0-squashfs-sysupgrade.bin |8650756|


 u-boot-spl.img 进行了补0，填充到了128K
 u-boot-spl.img + u-boot.img 组成了 uboot_full.img

<br> <br/>
<br> <br/>

 - 启动后

<table class="inline">
	<tbody><tr class="row0">
		<th class="col0"> Layer0 </th><td class="col1 centeralign" colspan="8">  raw flash 16M </td>
	</tr>
	<tr class="row1">
		<th class="col0"> Layer1 </th>
		    <td class="col1 centeralign" rowspan="1" colspan="3">  uboot  partitions  </td>
            <td class="col2 centeralign" rowspan="3" colspan="1"> <strong><code>mtd3</code></strong> factory <br />64K</td>
            <td class="col3 centeralign" colspan="3">  <strong><code>mtd4</code></strong><br /> firmware <br />15744K </td>
	</tr>
	<tr class="row2">
		<th class="col0"> Layer2 </th>
		    <td class="col1 centeralign" rowspan="2" > <strong><code>mtd0</code></strong> <br /> spl_loader <br />128k  </td>
		    <td class="col2 centeralign" rowspan="2">  <strong><code>mtd1</code></strong> <br /> uboot <br />384K    </td>
		     <td class="col3 centeralign" rowspan="2">  <strong><code>mtd2</code></strong> <br /> uboot_env <br />64k   </td>
		    <td class="col4 centeralign" rowspan="2">   <strong><code>mtd5</code></strong> <br /> kernel <br /> 1477K <br /> uImage_lzma</td>
		    <td class="col5 centeralign" rowspan="1" colspan="2">  <strong><code>mtd6</code></strong>
		    <br/>rootfs <br />14267K<br />mounted: "<code>/</code>" </td>
	</tr>
	<tr class="row3">
		<th class="col0"> Layer3 </th>
		    <td class="col1 centeralign" colspan="1">                                                          <strong><code>/dev/root</code></strong> <br />
                mounted: "<code>/rom</code>"<br />5371K<br />
                 root.squashfs (increase in 256K for mkfs with block size 256K)
            </td>
            <td class="col2 centeralign"  colspan="1">             
                <strong><code>mtd7</code></strong> <br /> rootfs_data <br /> 8896K<br />
                mounted: "<code>/overlay</code>" <br />
                used:632K
            </td>
	</tr>
</tbody></table>



##优化目标
最终目标为4M flash。分区划分情况如下：

 - 分区划分

| 分区名        | 大小   |
| --------   | -----:  |
| UBOOT SPL| 32K|  
| UBOOT        |   164K    |
| FACTORY|    4K   |
|SYSTEM|   3896K|
|SUM|   4096K|

结合目前调研看到的一些镜像数据。
编译的镜像大小

 - 镜像大小

| 分区       | 镜像| 大小   |
| --------   | ------- |-----:  |
| UBOOT SPL| u-boot-spl.img|  32K|
| UBOOT |    u-boot.img   | 164K|
|FIRMWARE | openwrt-siflower-sf16a18-mpw0-squashfs-sysupgrade.bin |3000K|      

余下空余空间896K
系统镜像中，其中
kernel 需要小与   1200K
root-fs 需要小于  1800K


###各个模块优化

根据重点的几个模块，列出下面优化的一些重点方向

 - WiFi 优化                       
wifi lmac 优化                    
wifi 总体优化                      

- OpenWrt系统优化               
openWrt 配置裁剪,文件裁剪          

- kernel优化                        
内核配置裁剪                      
内核自研驱动优化                  

- LuCI 优化
Luci lua文件优化， html资源裁剪

- Uboot 优化
Uboot 配置裁剪
Uboot 自研驱动优化

###TODO

 - 采用什么方式定义此方案，以单独配置文件方式，还是采用单独分支。（配置文件是否可以满足需求）
 openwrt 采用配置文件，个别软件包已单独裁剪版本发布
 kernel 采用专门flash 优化config

 - 如何保证在flash过小的情况下，不会出现由于剩余空间耗尽导致系统程序无法启动。
 调研出现空间耗尽对系统的影响。

##优化计划
 ```mermaid
 gantt
     dateFormat  YYYY-MM-DD
     title Flash Optimize
     section 前期准备
         准备开发分支            :done,         2018-01-15, 1d
         各个模块制定优化计划     :done,    a1,  2018-01-15, 2d
         review,讨论优化目标     :done,    a2,  after a1,   1d

     section 第一阶段
         第一阶段目标 ( OpenWrt系统 配置裁剪)周末  :active, a3,after a2,  5d
         第一阶段目标 ( OpenWrt系统 文件裁剪)      :a4,after a3,  2d
         第一阶段目标 ( kernel 部分 )  周末      :active, a5,after a2,    5d  
         测试 第一阶段验证  周末                 :crit, after a4, 7d

     section 第二阶段
         第二阶段目标 WiFi 优化  2周末           :active, after a2, 12d
         第二阶段目标 WiFi lmac优化 2周末        :a8, 2018-01-22, 15d
         第二阶段目标 ( uboot部分 )  周末        :a5,2018-01-22,    5d  
         第二阶段目标 LuCI 优化 周末             :a7, after a4, 7d
         第二阶段目标 ( kernel 部分 spi驱动)     :a6,after a5, 3d  
         第二阶段目标 ( uboot部分 网络)  周末      :a9,2018-01-29,  5d  
         第二阶段目标 ( uboot部分 spi)  周末      :a10, after a6,    3d  
         第一阶段目标 ( kernel 部分 以太网驱动)     :after a7, 3d  

         测试 第二阶段验证   周末                :crit, after a10, 7d

     section 发布验收
         准备发布(合并到master):                after a9, 2d
         发布并测试:                            after a8, 5d
 ```
