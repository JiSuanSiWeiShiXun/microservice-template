# youlingserv
我本来是想做一个IM消息转发器的。但是想着让这个转发服务支持http rpc等多种协议，这件事就很微服务。
再想到之前实现的IT资产管理平台bartender的后端，使用了wire viper zap等工具，各种服务都完全可以复用。很自然而然地想把这些东西整合起来，搞一套服务脚手架模板。

所以这个项目的第一个目标就变成了：基于 Go 语言构建的微服务框架示例，集成
1. hertz框架 实现 http服务
2. grpc框架 实现 rpc服务
3. [todo](youling15122511@gmail.com): kiteX框架
4. wire工具 实现依赖注入（解耦）
5. mockgen工具 实现接口mock（uber版本）
6. zap日志
7. viper配置
8. [todo](youling15122511@gmail.com): dal
9. [todo](youling15122511@gmail.com): pyroscope性能监控
9. [todo](youling15122511@gmail.com): metrics监控
9. [todo](youling15122511@gmail.com): tracing链路追踪
10. [todo](youling15122511@gmail.com): 使用 spiceDB+keycloak 中间件实现登录和权限控制
11. [todo](youling15122511@gmail.com): testify 分组单元测试
12. 各层面向接口编程

要点：
1. layout：
   - internal/ 目录下除了shared/模块外，其他模块均为各自服务独立实现
   - shared/ 下可以实现共享的biz、dal逻辑，以及共享的middleware、model等
   - model也可以再各自服务实现的目录下定义，比如不同服务读写同一张表的部分字段时
2. 依赖注入，
   依赖注入的好处是删除依赖时，只需要修改提供者函数即可，不需要改动使用者代码
   - 概念
      - provider：用于构造被依赖的对象的函数，没有依赖注入也要实现的普通函数
      - injector：组织provider函数
   - 使用wire实现了依赖注入，wire最佳实践：
      - wire.go代码放在cmd/服务名/目录下
      - 
3. 在复杂编程场景下还有一个domain层的概念，可以进一步解耦业务逻辑和传输模型
   - 目前项目中还没有体现
   - 贫血模型 vs 富血模型