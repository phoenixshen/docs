# 吞吐自动化测试case开发计划

标签（）： Autotest

---

## 目的
实现WIFI/以太网性能测试自动化

## 特性
考虑可移植性，测试兼容性（能测试多台路由）
**局限性**：此套程序只适用于单向/双向 TX/RX性能测试，LAN-WAN，LAN-LAN，1对多等复杂场景还需考虑实验室环境

## 框架流程介绍
以太网吞吐：
```seq
Title: Ethernet Throughput
XXL->Router: socket
XXL->PC: socket
Router--PC: TP-link SWITCH
```
WIFI吞吐：
```seq
Title: Wireless Throughput
XXL->Router: socket
XXL->PC_Wireless: socket
PC_Wireless-->Router: wireless card
```

## 开发计划
策划本计划分为四个阶段：
第一阶段：打通PC端程序，在PC上搭建自动化测试程序，保证远程调度平台能正常调度执行PC端测试脚本
第二阶段：WIFI吞吐，控制PC端无线网卡连接指定WIFI
第三阶段：WIFI吞吐/以太网吞吐，测试脚本实现，起TCP/UDP Server/Client进行Iperf测试
第四阶段：系统性测试 && BUG FIX

### 时间安排
第一阶段：20180418 （周三）
第二阶段/第三阶段：20180419～20180420 （周四、周五）
第四阶段：20180423~201804 （下周一、周二）

### 重难点
1、PC端程序适配（shell有差异，fifo用法不通等兼容性问题），是单独起一套程序还是直接移植过来；（直接移植过来脚本和log文件会放在根目录，涉及到执行修改权限等问题；单独起一套程序将脚本放在用户目录，会导致可移植性差，需要人维护等问题【代码是否需要上传】）
2、控制PC无线网卡连接指定WIFI需要使用sudo，怎么在shell脚本中使用管理员权限。

## 测试




