
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
mmap file 中的数据结构
主要是讲mac 和url 两个链表结构的数据进行了扁平化处理。

mac list size is the mmap file size
data used in ssst and dnsmasq
```puml
@startuml
class flat_mac_list{
<size:14> char operate_mac[6]
//add 0 /change 1/delete2  of the mac   or init3 of the list /after process in dnsmasq
//set none -1;
<size:14> char operate_type
// unsigned short
<size:14> char node_count[2] </size>
// each node size:  9 byte
// all size:        9* node count
<size:14> char* flat_mac_node_hdr_array
//all node  data
<size:14> char* flat_url_list array
}

class flat_mac_node_hdr{
// only one table  will be used
// unsigned short
<size:14>   char len[2]
<size:14>   char mac[6]
<size:14>   char listtype
}

class flat_url_list{
  //unsigned short
<size:14> char node_count[2] </size>
// each mode size 2
// all size 2 * node_count
<size:14> char* node_len_array
  ..
// data area
// url node is just string
<size:14> char *   url string
}
flat_mac_list *-- flat_mac_node_hdr
flat_mac_list *-- flat_url_list
@enduml
```
data saved in ssst
```puml
@startuml
class mac_list{
// unsigned short
<size:14> char node_count[2] </size>
// each node 11  
//all size : 11* node count
<size:14> struct mac_node_hdr_array
//all data
<size:14> char* url list array
}

class mac_node_hdr{
// unsigned short
<size:14>   char black_url_data_len[2]
// unsigned short
<size:14>   char white_url_data_len[2]
<size:14>   char mac[6]
<size:14>   char list_func
}

class url_list{
<size:14> char* black_list_str </size>
<size:14> char* white_list_str
}
mac_list *-- mac_node_hdr
mac_list *-- url_list
@enduml
```
