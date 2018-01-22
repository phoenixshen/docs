
# DNS 过滤插件

增加ipset配置（所有使能黑白名单功能的mac地址），配合iptable规则，将所有对于53端口的请求，强制转发到本地dnsmasq

dnsmasq对于dnsrequest的处理

```puml
@startuml
hide footbox
title DNS FILTER
actor user_request #Lime
participant dnsmasq #Cyan
participant dns_filter #Cyan
participant kernel #Cyan

autonumber
user_request-> dnsmasq: dns request
activate dnsmasq

dnsmasq -> dns_filter : check_dns_request()
note left:check_dns_listeners()
activate dns_filter

dns_filter->kernel :  ioctl arp search

kernel-> dns_filter : return mac

dns_filter->dns_filter : check mac filter in mac list
dns_filter->dns_filter : check url  in urllist
note left: share memory is managerd in ssst, update when user changes, use mmap

dns_filter-> dnsmasq: could access
deactivate dns_filter

dnsmasq-> dnsmasq:drop or continue

dnsmasq->user_request: result
deactivate dnsmasq
note left:cound be fake result if we like

@enduml
```

插件流程如上图所示

TODO:如何动态更新dnsmasq中的urllist
使用mmap的方式，ssst管理一块 mac list 和 urllist， dns filter 直接使用list进行 mac和url的匹配
url 使用子串匹配的方式进行过滤。

最终数据msync 的方式保存到实际文件中去。解决永久保存问题。

ssst 使用signal 通知dns filter 更新 内部list

url list配置直接写入文件
```puml
@startuml
hide footbox
title URL List Share Memory
actor user_change #Lime
participant Luci#Cyan
participant ssst #Cyan
participant dns_filter#Cyan

autonumber
user_change -> Luci: url list change
activate Luci

Luci -> ssst: send to ssst
deactivate Luci
activate ssst

ssst->ssst: save new urllist
ssst->ssst:  update share memory
ssst->ssst:  msync save to file
ssst->dns_filter: notify change
deactivate ssst
activate  dns_filter

dns_filter->dns_filter: update list

@enduml
```
