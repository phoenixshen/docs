#Home Control 接口定义

### 更改接口

- **/api/sfsystem/qos_info**

    功能 获取qos相关信息
    方式 APP + 路由器
    以http get的形式提交查询
    支持版本 V12
    备注:此接口依赖于和国云合作

    <pre><code>
    params: version
    return：  
    {
      "enable": 0,              //代表当前qos功能是否开启，1表示开启，0表示关闭
      “code”: 0,                //返回码
      “msg”: “error message”    //返回码不为0时会有错误信息返回
    }
    </code></pre>

- **/api/sfsystem/qos_set**
  功能 设置QOS的模式
  以http pos的形式提交修改
  支持版本 V12
  <pre><code>
  param： version
          enable
  return  {
    “code”: 0,              //返回码
    “msg”: “error message”  //返回码不为0时会有错误信息返回
  }
    </code></pre>

- **/api/sfsystem/setdevice**
  功能 设置client的各类信息
  以http post的形式提交变更
  支持版本 V12
  <pre><code>
  param:  version
          mac
          [internet]    // [0/1/2]  0 :disable internet 1 enable internet 2 refs timelist
          [lan]         // 代表是否允许接入lan口，取值1表示允许访问，否则不能访问
          [notify]      // 代表是否接收上线离线通知，取值1表示接收，否则不接收
          [disk]        // 代表能否访问路由器硬盘，取值1表示可以访问，否则不能访问
          [nickname]    // 代表当前设备的别名
  body:// set timelist， only avaliable when internet is 1
          {
            "timelist"：[
              {
                "enable": "[0/1]", //时间段是否禁止访问
                "starttime": "xx:xx",
                "endtime": "xx:xx"
                "week":"1,2,3,4,5,6,7"
                "config":"1"
              },

              {
                "enable": "1", //时间段是否禁止访问
                "starttime": "xx:xx",
                "endtime": "xx:xx"
                "week":"1,2,3,4,5,6,7"
                "config":"0"
              },
            ... //多个时间段
            ]  
          }
  return:
          {
            “code”: errorCode,//返回错误码
            “msg”: “error message”//errorCode不为0时返回错误信息
          }
  </code></pre>

- **/api/sfsystem/device_list**
功能 获取路由器上所有连接设备信息，包括在线、离线
以http get的形式提交查询
支持版本 V9
<pre><code>
param:  version
        type [0/1/2/3] //default 0, 0 all device include off-line 1 online device
                          2 online device count 3 single device
        [mac] bind with type3

//when type 0 or 1
return:
      {
        "list": [
          {
            "hostname": "android-f77e95d4560d37af", //设备实际接入名称
            "nickname": "Zhanggong", // 修改备注后名称
            "mac": "CC:2A:60:D0:62:EE", //设备mac地址
            "online": 0, //是否在线
            "ip": "191.167.30.237", //设备ip地址，离线则返回-1.-1.-1.-1
            "port": 0,//设备连接类型，-1为有线,0为无线
            "dev": "wl0",//连接路由器网络端口名称

            "authority": { //设备权限相关信息
              "internet": 0,//是否运行互联网访问
              "lan": 0,//是否允许接入路由器
              "listfunc" : 0  //0 no use 1 使用白名单 2 使能黑名单
              "speedlimit" : 0 //是否开启了限速功能
              "notify": -1,//上线离线通知
              "speedlvl": -1,//网速优先级别
              "disk": -1,//访问全盘数据()
              “limitup”: -1//网速上行限制，单位KBytes/s
              “limitdown”: -1//网速下行限制，单位KBytes/s
            },

            "timelist"：[
              {
                "enable": [1/0], //时间段是否禁止访问
                "starttime": "xx:xx",
                "endtime": "xx:xx"
                "week":"1,7"
                "config": "1"
              },
            ... //多个时间段
            ],

            "speed": { //设备网络速度相关信息
              "maxdownloadspeed": "76395",//最大下载速度
              "uploadtotal": "1130816",//上传总流量Bytes
              "upspeed": "29",//实时上传速度,单位Bytes/s
              "downspeed": "-1",//实时下载速度.单位Bytes/s
              "online": "19069",//本次连接时间
              "maxuploadspeed": "30289",//最大上传速度
              "downloadtoal": "1612667"//下载总流量Bytes
            }
          },
          ...
        ],// list would be empty when get fail
        “code”: -1, //返回码,code为-1代表获取数据成功
        “msg”: “OK” //表示接口执行正常 or return error string
      }

//when type 3
return:
      {
        "list":
        {
            "hostname": "android-f77e95d4560d37af", //设备实际接入名称
            "nickname": "Zhanggong", // 修改备注后名称
            "mac": "CC:2A:60:D0:62:EE", //设备mac地址
            "online": 0, //是否在线
            "ip": "191.167.30.237", //设备ip地址，离线则返回-1.-1.-1.-1
            "port": 0,//设备连接类型，-1为有线,0为无线
            "dev": "wl0",//连接路由器网络端口名称

            "authority": { //设备权限相关信息
              "internet": 0,//是否运行互联网访问
              "lan": 0,//是否允许接入路由器
              "listfunc" : 0  //0 no use 1 使用白名单 2 使能黑名单
              "speedlimit" : 0 //是否开启了限速功能
              "notify": -1,//上线离线通知
              "speedlvl": -1,//网速优先级别
              "disk": -1,//访问全盘数据()
              “limitup”: -1//网速上行限制，单位KBytes/s
              “limitdown”: -1//网速下行限制，单位KBytes/s
            },

            "timelist"：[
              {
                "enable": [1/0], //时间段是否禁止访问
                "starttime": "xx:xx",
                "endtime": "xx:xx"
                "config": "1"
              },
            ... //多个时间段
            ],

            "speed": { //设备网络速度相关信息
              "maxdownloadspeed": "76395",//最大下载速度
              "uploadtotal": "1130816",//上传总流量Bytes
              "upspeed": "29",//实时上传速度,单位Bytes/s
              "downspeed": "-1",//实时下载速度.单位Bytes/s
              "online": "19069",//本次连接时间
              "maxuploadspeed": "30289",//最大上传速度
              "downloadtoal": "1612667"//下载总流量Bytes
            }
        }
        “code”: -1, //返回码,code为-1代表获取数据成功
        “msg”: “OK” //表示接口执行正常 or return error string
      }

//when type 2
return:
        {
          “online”: 1
        }
</code></pre>
###新增接口

- **/api/sfsystem/setspeed**
功能 设置连接设备的限速信息
以http post的形式提交变更
支持版本 V12

<pre><code>
  param:  version
          mac
          [enable]    //使能限速 0 关闭 1 开启
          [limitup]   //bind with enable 1 代表网速上行限制，单位KBytes/s -1 不限速
          [limitdown] //bind with enable 1 代表网速下行限制，单位KBytes/s -1 不限速

  return:
        {
          “code”: errorcode,//返回错误码
          “msg”: “error message”//errorcode不为0时返回错误信息
        }
</code></pre>

- **/api/sfsystem/urllist_set**
功能 设置黑白名单
以http pos的形式提交修改
支持版本 V12
<pre><code>
param:  version
        listtype [0/1] //代表获取白名单或黑名单，0 白名单， 1 黑名单
        mac
body:
      {
          "urllist"：[ "url1", "url2", .. ] // input url here  
          "urllist_en"：[ "url1", "url2", .. ] // input url here  
      }

return:
      {
        “code”: 0,//返回码
        “msg”: “error message”//返回码不为0时会有错误信息返回
      }
</code></pre>
``
- **/api/sfsystem/urllist_get**
功能 获取黑白名单
以http get的形式提交查询
支持版本 V12
<pre><code>
param:  version
        listtype [0/1] //代表获取白名单或黑名单，0 白名单， 1 黑名单
        mac
return:
        {
          “urllist”：["url1","url2", ...] //web 列表数组
          “code”: 0,//返回码
          “msg”: “error message”//返回码不为0时会有错误信息返回
        }
</code></pre>


- **/api/sfsystem/urllist_enable**
功能 设置黑白名单
以http pos的形式提交修改
支持版本 V12
<pre><code>
param:  version
        listfunc// 0 no use 1 使用白名单 2 使能黑名单
        mac // 设备mac地址
return:
      {
        “code”: 0,//返回码
        “msg”: “error message”//返回码不为0时会有错误信息返回
      }
</code></pre>
