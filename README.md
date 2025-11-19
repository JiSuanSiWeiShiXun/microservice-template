# Impirrot

一个基于 Go 的微服务项目，采用 Hertz（HTTP）+ gRPC 混合架构。

## 📦 技术栈

- **HTTP 框架**: [Hertz](https://github.com/cloudwego/hertz) - 高性能 HTTP 框架
- **RPC 框架**: [gRPC](https://grpc.io/) - 高性能 RPC 框架
- **依赖注入**: Wire（可选）
- **日志**: zap
- **配置**: viper
- **ORM**: GORM
- **测试**: mockgen（接口 mock）

## 🏗️ 目录结构

```
impirrot/
├── api/                          # Proto 定义
│   ├── adhoc/
│   │   └── v1/
│   │       └── adhoc.proto
│   └── common/
│       ├── types.proto
│       ├── common.proto
│       └── error.proto
│
├── gen/                          # 生成代码
│   ├── go/
│   ├── python/
│   └── ...
│
├── cmd/                          # 服务入口
│   ├── api-gateway/              # HTTP 网关（端口: 8080）
│   │   └── main.go
│   ├── adhoc-server/             # Adhoc gRPC 服务（端口: 50051）
│   │   └── main.go
│   └── logic-server/             # Logic gRPC 服务（待实现）
│       └── main.go
│
├── internal/                     # 内部实现
│   ├── shared/                   # ⭐ 跨服务共享模块
│   │   ├── auth/                 # 权限模块（SpiceDB/Casbin）
│   │   │   ├── client.go
│   │   │   └── checker.go
│   │   ├── middleware/           # 中间件/拦截器
│   │   │   ├── http/             # HTTP 专用中间件
│   │   │   │   ├── auth.go
│   │   │   │   ├── cors.go
│   │   │   │   └── metrics.go
│   │   │   └── grpc/             # gRPC 专用拦截器
│   │   │       ├── auth.go
│   │   │       ├── recovery.go
│   │   │       └── metrics.go
│   │   └── model/                # ⭐ 共享 ORM 模型
│   │       └── user.go
│   │
│   ├── api/                      # API Gateway 服务实现
│   │   ├── handler/              # HTTP handlers
│   │   │   ├── handler.go
│   │   │   └── converter.go      # DTO → Model 转换
│   │   ├── biz/                  # 业务逻辑层
│   │   │   └── hello_service.go
│   │   ├── dal/                  # 数据访问层
│   │   │   └── user_dal.go
│   │   └── middleware/           # 网关特有中间件
│   │       └── rate_limit.go
│   │
│   ├── adhoc/                    # Adhoc 服务实现
│   │   ├── service/              # gRPC service 实现
│   │   │   ├── adhoc_service.go
│   │   │   └── converter.go      # Proto → Model 转换
│   │   ├── biz/                  # 业务逻辑层
│   │   │   └── adhoc_biz.go
│   │   └── dal/                  # 数据访问层
│   │       ├── adhoc_dal.go
│   │       └── model/            # ⭐ Adhoc 专用 Model
│   │           └── adhoc_user.go
│   │
│   └── logic/                    # Logic 服务实现（待实现）
│       ├── service/
│       ├── biz/
│       └── dal/
│
├── pkg/                          # ⭐ 可跨项目复用的公共库
│   ├── config/                   # 配置加载（viper）
│   ├── log/                      # 日志封装（zap）
│   ├── database/                 # 数据库连接池
│   │   ├── mysql.go
│   │   └── redis.go
│   ├── observability/            # 可观测性
│   │   ├── metrics.go            # Prometheus 指标
│   │   ├── tracing.go            # 链路追踪
│   │   └── logging.go
│   └── dto/                      # 数据传输对象
│       └── common_dto.go
│
├── deploy/                       # 部署配置
├── scripts/                      # 构建脚本
├── docs/                         # 文档
├── config.yml                    # 配置文件
└── Makefile
```

## 🚀 快速开始

### 1. 安装依赖

```bash
go mod download
```

### 2. 生成 Proto 代码

```bash
make proto
# 或者
./scripts/build-proto.sh
```

### 3. 启动服务

#### 启动 Adhoc gRPC 服务

```bash
go run cmd/adhoc-server/main.go
```

#### 启动 API Gateway

```bash
go run cmd/api-gateway/main.go
```

### 4. 测试接口

#### 测试 HTTP API

```bash
curl -X POST http://localhost:8080/api/v1/hello \
  -H "Content-Type: application/json" \
  -H "X-User-ID: user123" \
  -d '{"name": "Alice"}'
```

#### 测试 gRPC

```bash
grpcurl -plaintext \
  -d '{"name": "Bob"}' \
  -H 'user-id: user123' \
  localhost:50051 \
  adhoc.v1.AdhocService/Hello
```

## 📋 架构设计

### 分层架构

```
┌─────────────────────────────────┐
│   Handler/Service Layer         │  ← HTTP/gRPC 入口
├─────────────────────────────────┤
│   Business Logic (Biz)          │  ← 业务逻辑层
├─────────────────────────────────┤
│   Data Access Layer (DAL)       │  ← 数据访问层
├─────────────────────────────────┤
│   Database / External Services  │  ← 基础设施
└─────────────────────────────────┘
```

### 关键设计决策

1. **共享模块独立**: `internal/shared/` 存放跨服务共享的代码（auth、middleware、model）
2. **HTTP 和 gRPC 中间件分离**: 签名不同，无法共用，但核心逻辑可抽取到 `pkg/observability/`
3. **服务专用 Model**: 每个服务可以有自己的专用 Model（如 `adhoc/dal/model/`）
4. **转换器模式**: 使用 `converter.go` 处理 Proto ↔ Model、DTO ↔ Model 转换

### 中间件/拦截器

- **HTTP 中间件** (`internal/shared/middleware/http/`)
  - 鉴权 (AuthMiddleware)
  - CORS (CORSMiddleware)
  - 指标上报 (MetricsMiddleware)
  - 限流 (RateLimitMiddleware) - 仅 API Gateway

- **gRPC 拦截器** (`internal/shared/middleware/grpc/`)
  - 鉴权 (AuthInterceptor)
  - Panic 恢复 (RecoveryInterceptor)
  - 指标上报 (MetricsInterceptor)

## 🔧 配置

编辑 `config.yml` 配置数据库、日志等参数：

```yaml
log:
  level: info

db:
  host: localhost
  port: 3306
  user: root
  pwd: password
  database: impirrot
```

## 📝 待办事项

- [ ] 集成 Wire 依赖注入
- [ ] 实现 Logic 服务
- [ ] 集成 SpiceDB/Casbin 权限系统
- [ ] 集成 Prometheus 监控
- [ ] 集成 OpenTelemetry 链路追踪
- [ ] 添加单元测试
- [ ] Docker 化部署

## 📚 相关文档

- [架构分析](docs/ARCHITECTURE_ANALYSIS.md)
- [多语言代码生成](docs/MULTI_LANGUAGE_CODEGEN.md)
- [Proto 构建指南](docs/PROTO_BUILD.md)

---

**注意**: 某些微服务可能有重合的数据读写和逻辑，可以放在 `internal/shared/` 共享，但要权衡复用与耦合的代价。