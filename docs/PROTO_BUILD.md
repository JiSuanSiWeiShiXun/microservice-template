# Protocol Buffers 编译系统

这个项目使用了一套完整的 Protocol Buffers 编译和管理系统，支持复杂的目录结构和自动化编译流程。

## 目录结构

```
├── api/                          # Proto 文件目录
│   ├── common/                   # 通用/基础组件
│   │   ├── common.proto          # 通用响应结构
│   │   └── error.proto           # 错误码定义
│   └── v1/                       # API 版本目录
│       └── adhoc.proto           # 具体业务 API
├── gen/                          # 生成的代码目录
│   ├── common/                   # 对应 api/common/
│   │   ├── common.pb.go
│   │   └── error.pb.go
│   └── adhoc/v1/                 # 对应 api/v1/
│       ├── adhoc.pb.go
│       └── adhoc_grpc.pb.go
├── scripts/                      # 编译脚本
│   ├── build-proto.sh           # 主编译脚本
│   └── ci-build-proto.sh        # CI/CD 编译脚本
├── .github/workflows/           # GitHub Actions
│   └── proto.yml                # 自动编译工作流
├── Makefile                     # Make 构建配置
└── proto.config.toml            # 编译配置文件
```

## 快速开始

### 1. 安装依赖

```bash
# 安装 Protocol Buffers 编译器
# macOS
brew install protobuf

# Ubuntu/Debian
sudo apt-get install protobuf-compiler

# 安装 Go 插件
make install
```

### 2. 编译 Proto 文件

```bash
# 使用 Makefile (推荐)
make build          # 编译所有 proto 文件
make rebuild        # 清理并重新编译
make clean          # 清理生成的文件

# 或直接使用脚本
./scripts/build-proto.sh --clean
```

### 3. 开发模式

```bash
# 监控文件变化并自动编译
make watch

# 开发模式：清理、编译、验证、统计
make dev
```

## 编译脚本特性

### 主编译脚本 (`scripts/build-proto.sh`)

- ✅ 自动发现所有 `.proto` 文件
- ✅ 保持目录结构一致
- ✅ 依赖检查和验证
- ✅ 彩色日志输出
- ✅ 错误处理和报告

**使用方法:**
```bash
./scripts/build-proto.sh [选项]

选项:
  --clean     编译前清理输出目录
  --help      显示帮助信息

环境变量:
  PROTO_DIR   proto 文件目录 (默认: api)
  OUTPUT_DIR  输出目录 (默认: gen)
  PROTO_PATH  proto 搜索路径 (默认: api)
```

### CI/CD 脚本 (`scripts/ci-build-proto.sh`)

专为持续集成环境设计的编译脚本，包含更严格的验证：

- ✅ 严格模式错误处理
- ✅ 生成文件差异检查
- ✅ Go 代码格式验证
- ✅ 编译和静态分析检查
- ✅ 文档生成支持

**环境变量:**
```bash
CI_MODE=true          # CI 环境模式
FAIL_ON_DIFF=true     # 差异检测失败时退出
GENERATE_DOCS=false   # 是否生成文档
```

## Makefile 命令

| 命令 | 描述 |
|------|------|
| `make build` | 使用脚本编译所有 proto 文件 |
| `make build-simple` | 直接使用 protoc 编译 (适合简单项目) |
| `make clean` | 清理生成的文件 |
| `make rebuild` | 清理并重新编译 |
| `make list` | 列出所有 proto 文件 |
| `make check` | 检查依赖和环境 |
| `make install` | 安装编译依赖 |
| `make watch` | 监控文件变化并自动编译 |
| `make verify` | 验证生成的代码 |
| `make stats` | 显示生成文件统计 |
| `make dev` | 开发模式：清理、编译、验证、统计 |
| `make help` | 显示帮助信息 |

## 自动化集成

### GitHub Actions

项目配置了完整的 GitHub Actions 工作流 (`.github/workflows/proto.yml`)：

1. **编译检查**: 在 PR 和推送时自动编译验证
2. **代码检查**: 验证生成的代码格式和编译
3. **差异检查**: 确保提交包含最新的生成文件
4. **Lint 检查**: 使用 buf 进行 proto 文件规范检查
5. **文档生成**: 自动生成 API 文档并部署到 GitHub Pages

### 本地开发工作流

```bash
# 1. 修改 proto 文件
vim api/v1/new_service.proto

# 2. 编译并验证
make dev

# 3. 提交代码 (包含生成的文件)
git add .
git commit -m "feat: add new service API"
git push
```

## 高级配置

### 自定义编译选项

修改 `proto.config.toml` 文件来自定义编译行为：

```toml
[default]
proto_dir = "api"
output_dir = "gen"

[go]
go_opt = "paths=source_relative"
grpc_opt = "paths=source_relative"

[plugins.optional]
# 启用额外插件
grpc-gateway = { enabled = true, out = "gen/gateway" }
openapi = { enabled = true, out = "docs/api" }
```

### 多环境支持

```bash
# 开发环境
PROTO_DIR=proto-dev make build

# 生产环境配置
CI_MODE=true FAIL_ON_DIFF=true ./scripts/ci-build-proto.sh
```

## 常见问题

### Q: 如何添加新的 proto 文件？

只需在 `api/` 目录下创建 `.proto` 文件，脚本会自动发现并编译。

### Q: 如何处理导入路径问题？

确保 proto 文件中的 import 路径相对于 `api/` 目录：
```protobuf
import "common/common.proto";  // 正确
import "api/common/common.proto";  // 错误
```

### Q: 如何在 CI 中集成？

使用 CI 专用脚本：
```bash
CI_MODE=true ./scripts/ci-build-proto.sh
```

### Q: 如何启用文件监控？

```bash
# 需要先安装 fswatch (macOS)
brew install fswatch

# 然后启动监控
make watch
```

## 维护指南

### 添加新的编译插件

1. 在 `scripts/build-proto.sh` 中添加插件配置
2. 更新 `Makefile` 中的依赖检查
3. 修改 CI 脚本安装对应插件
4. 更新文档

### 版本升级

定期更新以下组件：
- protoc 编译器版本
- Go 插件版本 (`protoc-gen-go`, `protoc-gen-go-grpc`)
- GitHub Actions 版本

## 参考资料

- [Protocol Buffers 官方文档](https://developers.google.com/protocol-buffers)
- [gRPC Go 快速开始](https://grpc.io/docs/languages/go/quickstart/)
- [Buf 样式指南](https://docs.buf.build/lint/overview)