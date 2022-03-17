# mms_app

#### 简介
mms_app是基于OpenHarmony系统ETS UI框架开发的短信项目，主要的功能包含信息查看、发送短信、接收短信、短信送达报告、删除短信等功能；

#### 架构图
主要针对架构目标、关键架构需求、假设和约束加以说明，对架构的原则性进行必要说明，针对架构的相关视图，进行绘制并加以说明（主要包含用例视图、逻辑视图、开发视图、部署视图、运行视图）。

![screenshot-20211129-202627](./doc/image/screenshot-20211129-202627.png)

#### 目录

/mms/
├── entry                               		# 主entry模块目录
│    ├── src		
│      ├── main		
│        └── ets                         		# js代码目录
│          └── default		
│              └── data                 		# 自定义数据类型
│			   └── model                		# 对接数据库
│			   └── pages                		# 页面
│				 └── conversation       		# 会话详情页面
│				 └── conversationlist     		# 信息列表页面
│				 └── index                     	# 首页
│				 └── info_msg                	# 通知信息列表页面
│				 └── query_report               # 报告详情页面
│				 └── settings                  	# 设置页面
│			   └── service             			# 业务逻辑
│			   └── utils               			# 工具类
│			   └── views               			# 自定义组件
│          └── ServiceAbility                   # 后台常驻服务
│        └── java                 			    # Ability
│        └── resources                 			# 资源存放目录
│        └── config.json               			# 全局配置文件
├── gradle                             			# gradle
│    ├──wrapper


