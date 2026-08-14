# 信息应用
-   [简介](#简介a-nameintroductiona)
    -   [内容介绍](#内容介绍a-namecontent-introductiona)
    -   [架构图](#架构图a-namearchitecturea)
-   [目录](#目录a-namedirectory-structurea)
-   [相关仓](#相关仓a-namerepositories-involveda)

## 简介<a name="Introduction"></a>

### 内容介绍<a name="Content-Introduction"></a>
信息应用是OpenHarmony标准系统中预置的系统应用，为用户提供基础的信息功能，包括信息支持短信通知收藏与小区广播、信息支持短信会话详情及操作、信息支持信息接收、信息支持短信、信息支持短信应用开源资料等能力。 

**核心功能：**

1. **短信核心功能**：支持发送（含长短信）、接收、转发、重发（失败消息）及删除（单条或批量）短信；支持短信群聊。
2. **消息通知与收藏**：显示消息通知，支持标记已读、直接回复；支持收藏重要消息，方便后续查看。
3. **会话管理**：提供便捷的消息列表，支持左滑删除、长按多选、滑动选择等操作；消息列表页和详情页均显示联系人姓名及头像，识别更直观。
4. **消息详情操作**：支持对消息内容执行复制文本、选中文本片段、转发、保存、删除、呼叫等操作；
5. **通知消息处理**：将通知类消息整合至专属列表，支持全部已读、长按或滑动选择单条 / 批量删除。
6. **补充功能**：包括小区广播服务（CBS）支持、消息送达报告、消息铃声、还原默认设置。

### 架构图<a name="Architecture"></a>
![](./figures/img.png)

## 目录<a name="Directory-Structure"></a>

~~~
/applications_mms/
├── AppScope/                                 # 应用级资源与配置
├── entry
│   ├── src
│   │   ├── main
│   │   │   ├── cust/                         # 客制化代码
│   │   │   ├── ets/                          # ArkTS 业务代码
│   │   │   │   ├── Application/              # 应用入口与生命周期
│   │   │   │   ├── MainAbility/              # 主 Ability 入口
│   │   │   │   ├── PrivacyAbility/           # 隐私声明 Ability
│   │   │   │   ├── PushAbility/              # 推送消息 Ability
│   │   │   │   ├── StaticSubscriber/         # 静态订阅器（系统事件监听）
│   │   │   │   ├── ServiceExtension/         # 服务扩展能力（备份恢复/RPC/联系人服务等）
│   │   │   │   ├── backup/                   # 数据备份恢复模块
│   │   │   │   ├── chatbot/                  # 聊天机器人模块
│   │   │   │   ├── data/                     # 全局数据定义与常量
│   │   │   │   ├── flashMessage/             # 桌面弹窗消息（Flash Message）
│   │   │   │   ├── log/                      # 日志框架
│   │   │   │   ├── model/                    # 数据模型层
│   │   │   │   ├── oobe/                     # 开机向导（隐私声明）
│   │   │   │   ├── pages/                    # 所有页面
│   │   │   │   │   ├── conversation/         # 会话详情页
│   │   │   │   │   ├── conversationlist/     # 会话列表页
│   │   │   │   │   ├── infomsg/              # 通知信息列表页
│   │   │   │   │   ├── index/                # 应用首页
│   │   │   │   │   ├── settings/             # 设置页
│   │   │   │   │   ├── favoritepage/         # 收藏消息页
│   │   │   │   │   ├── groupdetail/          # 群组详情页
│   │   │   │   │   ├── groupcontactlist/     # 群组成员列表页
│   │   │   │   │   ├── queryreport/          # 送达报告详情页
│   │   │   │   │   ├── transmitmsg/          # 转发消息页
│   │   │   │   │   ├── slidePreview/         # 幻灯片预览页
│   │   │   │   │   ├── photoBrowser/         # 图片浏览器页
│   │   │   │   │   ├── FullImage/            # 全屏图片显示页
│   │   │   │   │   ├── managesim/            # SIM 卡管理页
│   │   │   │   │   ├── privacy/              # 隐私声明页
│   │   │   │   │   ├── copy/                 # 复制内容展示页
│   │   │   │   │   ├── lowMemoryCamera/      # 低内存模式相机页
│   │   │   │   │   ├── mmsurigrant/          # 消息授权页
│   │   │   │   │   ├── DeskDialog/           # 桌面弹窗对话框
│   │   │   │   ├── report/                   # 垃圾短信举报模块
│   │   │   │   ├── service/                  # 业务服务层
│   │   │   │   ├── utils/                    # 工具类库
│   │   │   │   └── views/                    # 自定义 UI 组件
│   │   │   │       ├── AttachmentArea/       # 附件区域组件
│   │   │   │       ├── MmsMap/               # map位置组件
│   │   │   │       ├── MmsAvatar/            # 头像组件
│   │   │   │       ├── MmsReceive/           # 消息接收处理
│   │   │   │       └── receive/              # 消息接收展示组件
│   │   │   └── ohosTest/                     # 测试代码
│   │   └── ohosTest/
│   ├── build-profile.json5                   # 构建配置
│   ├── hvigorfile.ts                         # 构建脚本
│   └── oh-package.json5                      # 包依赖配置
├── .gitignore
├── LICENSE
├── OAT.xml                                   # 兼容性测试配置
├── README-zh.md                              # 中文说明文档
├── README.md                                 # 英文说明文档
├── build-profile.json5                       # 工程级构建配置
└── build.sh                                  # 构建脚本
~~~

## 相关仓<a name="Repositories-Involved"></a>

[**applications_contacts**](https://gitcode.com/openharmony/applications_contacts)

[**telephony_telephony_data**](https://gitcode.com/openharmony/telephony_telephony_data)
