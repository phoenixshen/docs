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
