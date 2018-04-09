
# NPU驱动文档

本篇文档对于NPU硬件进行简单的介绍，着重对于软件功能和设计进行描述。

## 硬件功能介绍

NPU 硬件实现了一个10/100M 的五口交换机，通过内建的vlan功能的支持，可以划分虚拟的wan lan口。
硬件基于内建的vlan table 和 mac table对于报文进行switch，对于不能识别mac的报文，硬件punt到
软件进行处理，软件基于报文信息，配置好内部table后，再将报文发出。
这样可以在最大化利用硬件能力进行传输的同时，减少硬件的复杂度。

![image003](/assets/image003.png)

- 模块简介：

BMU模块：负责Alloc 和 Free buffer，管理LMEM。   
Classfier 模块：进行Switch，读取packet header内容，将packet进行classify and modify,然后传递到TMU
TMU模块：负责实现QoS流程，将packet按照放入优先级队列后然后发送到指定port
GPI模块：通过BMU获取buffer，将TMU传递的指针指向的数据copy到内部fifo。
		 通过BMU获取buffer，将内部fifo数据copy到LMEM,传递指针到classfier
TX:
HIF模块：负责将HOST 端buffer通过DMA复制到内部fifo中.fifo连接到GPI.
EMAC模块：负责将fifo中的数据packet传输出去
RX:
HIF模块：负责将fifo中的buffer 通过DMA传输到Host。
EMAC模块：负责将packet传递到内部fifo

## 驱动结构介绍

###软件架构
![image008](/assets/image008.png)

- 简介
驱动的基础功能包含了收发数据，mac地址学习和ageing，划分和管理vlan。
同时也通过sysfs节点，提供了一些硬件的特有功能的接口，包括设定特殊协议嗅探，设定QoS等。
灰色模块为自主开发的部分， Network Stack 和 Network Application 是kernel的原生模块。
其中，网络应用部分主要用来处理一些网路协议，通常一些网络管理相关协议 例如MRP STP 等，通常
数据量不大，处理速度要求也不高。
网络协议栈部分要求处理例如tcp/ip vlan 等协议，进行大量的数据交互。

<br> <br/>
- Switch 机制
![image011](/assets/image011.png)

驱动建立和管理系统中的抽象的网络设备来对应硬件设备，进行数据交互和管理。其中，Host 通过驱动
的控制接口对于硬件进行控制，以及驱动内部的mac 地址的学习 和管理属于slow path，数据被发送到host
进行了进一步处理。

根据已经设定好的mac地址信息，硬件直接转发报文到对应接口，成为fast path。

驱动需要对于每一个传输报文补充对应的 Buffer descripter 和 TX & RX header, 来告诉硬件如何获取和发送数据，同时，硬件收到需要软件处理的报文，会已punt的形式将报文传输给host，同是会带上对应的punt reason。
- MAC learn MAC ageing

意见提供了基于802.1q的mac地址转发功能，其中mac 地址的管理是由软件实现

learn:
 当报文的Source mac地址是未知的，报文会被punt到Host进行mac地址学习，host 创建对应的mac entry
记录这个mac地址。

relearn：
当已经学习过的mac地址，从另外一个端口出现的时候，报文会被punt到host，更新对应mac entry。

ageing：
周期性的将所有的mac entry进行标记，一个周期内，如果mac 地址仍然出现，则标记为正常 的mac entry，一个周期后，对没有再次出现的mac entry进行删除操作。

mac entry operation ：
如果mac entry被设置为static， 则不进行entry操作， 同时host 可以通过mac 地址或者是vlan id 对mac entry 进行删除操作。`   `





### 驱动编译选项说明 (注：默认编译及可选宏编译)
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

### 平台驱动流程

- 打开设备流程
![open_flow](/assets/open_flow.png)

       关闭设备流程

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

    为了节约NPU工作时的功耗，在phy不工作时，每一个PHY进入低功耗模式节约20mA电流    

    在检测到PHY没有link状态时，将PHY设置为10M半双工，TX模式设置为idle模式。

    由于我们是Router，为了防止PC网卡进入休眠模式后，导致双方同事休眠无法互相唤醒，我们会每1s，将phy wake 5ms，发送信号，保证对方网卡休眠也可以进行唤醒。

    检测到phy 上面有energy，此时将phy 切换到正常工作模式，建立link，正常通讯。

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
