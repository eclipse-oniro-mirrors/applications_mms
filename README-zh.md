# 信息应用
-   [简介](#简介a-nameintroductiona)
    -   [内容介绍](#内容介绍a-namecontent-introductiona)
    -   [架构图](#架构图a-namearchitecturea)
-   [目录](#目录a-namedirectory-structurea)
-   [相关仓](#相关仓a-namerepositories-involveda)

## 简介<a name="Introduction"></a>

### 内容介绍<a name="Content-Introduction"></a>
信息应用是OpenHarmony标准系统中预置的系统应用，为用户提供基础的信息功能，包括信息支持短信通知收藏与小区广播、信息支持短信会话详情及操作、信息支持信息接收、信息支持彩信、信息支持短信、信息支持短信应用开源资料等能力。 

**核心功能：**

1. **短信 / 彩信核心功能**：支持发送（含长短信）、接收、转发、重发（失败消息）及删除（单条或批量）短信和彩信；支持短信 / 彩信群聊，彩信可添加照片、录音、位置、联系人、幻灯片等附件。
2. **消息通知与收藏**：显示消息通知，支持标记已读、直接回复或复制验证码；支持收藏重要消息，方便后续查看。
3. **会话管理**：提供便捷的消息列表，支持左滑删除、长按多选、滑动选择等操作；消息列表页和详情页均显示联系人姓名及头像，识别更直观。
4. **消息详情操作**：支持对消息内容执行复制文本、选中文本片段、转发、保存（彩信附件）、删除等操作；验证码短信配备一键复制按钮，使用更便捷。
5. **通知消息处理**：将通知类消息整合至专属列表，支持全部已读、长按或滑动选择单条 / 批量删除。
6. **补充功能**：包括小区广播服务（CBS）支持、消息送达报告、双卡适配（发送消息时可切换卡 1 / 卡 2）。

### 架构图<a name="Architecture"></a>
![](./figures/img.png)

## 目录<a name="Directory-Structure"></a>

~~~
/Mms/
├── doc                                        # 资料
├── entry
│   └── src
│       └── main
│           └── ets                            # ets代码目录
│               └── default                    # 业务代码目录
│                   ├── data                   # 自定义数据类型
│                   ├── model                  # 对接数据库
│                   ├── pages                  # 所有页面
│                       ├── conversation       # 会话详情页面
│                       ├── conversationlist   # 信息列表页面
│                       ├── index              # 初始页面
│                       ├── infomsg           # 通知信息列表页面
│                       ├── queryreport       # 报告详情页面
│                       └── settings           # 设置页面
│                   ├── service                # 业务逻辑
│                   ├── utils                  # 工具类
│                   ├── views                  # 自定义组件
│                   └── app.ets                # 应用生命周期
│               └── StaticSubscriber           # 静态事件监听
│           ├── resources                      # 资源配置文件存放目录
│           └── config.json                    # 全局配置文件
├── signs                                      # 签名
└── LICENSE
~~~

## 相关仓<a name="Repositories-Involved"></a>

[**applications_contacts**]

[**telephony_sms_mms**]