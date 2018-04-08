# NPU驱动文档



## 硬件功能介绍

## 驱动结构介绍

## 驱动编译选项说明 (注：默认编译及可选宏编译)
可选宏及说明：可通过修改下列宏进行特定编译
| 宏                     | 默认 | 说明                    |
| ---------------------- | ---- | ----------------------- |
| SFAX8_SWITCH           | y    | 决定驱动编译为m/y/n     |
| SFAX8_PTP              | n    | 数据报时间戳支持        |
| SFAX8_SWITCH_FPGA      | n    | FPGA调试支持            |
| SFAX8_SWITCH_VLAN      | y    | 决定是否划分VLAN        |
| SFAX8_SWITCH_API       | n    | NPU特殊功能接口支持     |
| SFAX8_SWITCH_POWERSAVE | n    | PHY的睡眠模式优化功耗   |
| SFAX8_SWITCH_AGEING    | y    | 软件对MAC地址存储的支持 |
| SF_TX_SHUTDOWN         | y    | 配置端口优化功耗        |



## 驱动功能模块描述

## 平台驱动流程

       初始化

       打开设备

       关闭设备

       发送数据
            数据结构
            硬件处理方法

       接受数据
            数据结构
            硬件处理方法

       中断处理

## Phy link 机制介绍

## Switch 机制介绍

## 功耗优化方案介绍

**说明**：针对功耗优化，我们测试发现NPU主要耗电在PHY，每启用一个PHY增加约20mA电流，且PHY工作在10M半双工比100M全双工情况下更省电，修改TX发射功率也能略微减少功耗，因此我们对应设计了2套功耗优化方案。

    方案一：在检测到PHY没有link状态时，将PHY设置为10M半双工，TX模式设置为idle模式（1s sleep 5ms on）；
    优点：在路由器没有用户接入时，能较大节省功耗
    缺点：在端口被占用情况下等于没有省电

    方案二：在检测到PHY没有link状态时，将PHY设置为Power save模式（PHY断电，但部分寄存器工作），连接时重新设置为normal模式；
    优点：PHY处于断电时节省功耗最大
    缺点：PHY从断电到唤醒需要进过1.28s，耗时过久

## Recovery机制介绍 (注：reset线程介绍)

**说明**：为避免驱动遭遇意外情况而出现不可恢复的错误，我们增加了一个recovery保障机制。

**方法**：另起线程，循环检测NPU内部buffer使用情况，在检测到内部buffer耗尽且数据处理单元描述符TX/RX/Free index不走的情况下触发我们的recovery机制。

**特征**：recovery操作是一个平滑的用户无法感知的操作，耗时约100ms，它会记录当前index，并对NPU软硬件重新进行配置，配置完成后会从之前位置重新读取处理数据。

## api 特有接口介绍(对应驱动特别功能) (注：special func)


## DebugFS (注：各debug接口)

**位置**：/sys/kernel/debug/npu_debug

**方法**：使用标准文件系统接口，有read/write 2种如下调用方式

    cat /sys/kernel/debug/npu_debug
    echo XX > /sys/kernel/debug/npu_debug

**功能**：
### 1. 开启/关闭debug log

命令：echo XX > /sys/kernel/debug/npu_debug

| 值  | log             |
| --- | --------------- |
| 0   | ETH_TX_DEBUG    |
| 1   | ETH_RX_DEBUG    |
| 2   | ETH_IRQ_DEBUG   |
| 3   | SWITCH_DEBUG:   |
| 4   | ETH_POLL_DEBUG: |
| 5   | 关闭所有log     |

### 2. 唤醒队列

    说明：在检测到队列stop的情况下会重新start队列

    命令：echo 0x6 > /sys/kernel/debug/npu_debug

### 3. 获取所有端口Buffer使用情况/Dump tx_bd信息

    说明：在第二个参数不为1的情况下Dump所有端口内部buffer使用情况，在第二个参数为1时Dump所有tx_bd详细信息

    命令：echo 0x7 （0x1） > /sys/kernel/debug/npu_debug

### 4. 读/写PHY寄存器

    说明：在没有第四个参数的情况下读取PHY寄存器值，在有第四个参数情况下写PHY寄存器值

    命令：echo 0x8 （port） （addr） （value） > /sys/kernel/debug/npu_debug

### 5. 关闭PHY的power save模式/设置tx waketime

    说明：在开启power save宏的情况下关闭PHY的power save模式，否则设置tx waketime

    命令：echo 0x9 （port/value） > /sys/kernel/debug/npu_debug

### 6. PPPOE测试

    说明：驱动发送PPPOE lcp数据包

    命令：echo 0xa > /sys/kernel/debug/npu_debug

### 7. Reset测试/开启ETH_RESET_DEBUG log

    说明：在第二个参数为1的情况下执行NPU reset流程，否则开启reset debug log

    命令：echo 0xb （0x1） > /sys/kernel/debug/npu_debug

### 8. 获取tx、rx中断/数据包/队列状态信息

    命令：echo 0xc > /sys/kernel/debug/npu_debug

### 9. 检测多有端口连接状态

    命令：cat /sys/kernel/debug/npu_debug

