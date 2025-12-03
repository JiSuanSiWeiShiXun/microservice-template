# 多语言代码生成架构总结

## 📊 架构概览

```
youlingserv/
├── api/                           # Proto 定义文件（单一数据源）
│   ├── common/
│   └── adhoc/v1/
├── gen/                           # 生成的代码（多语言）
│   ├── go/                       # ✅ Go 语言
│   ├── python/                   # ✅ Python 语言
│   ├── typescript/               # ✅ TypeScript 语言
│   ├── java/                     # 🔧 Java 语言
│   ├── cpp/                      # 🔧 C++ 语言
│   ├── rust/                     # 🔧 Rust 语言
│   ├── swift/                    # 🔧 Swift 语言（iOS）
│   ├── kotlin/                   # 🔧 Kotlin 语言（Android）
│   └── dart/                     # 🔧 Dart 语言（Flutter）
├── scripts/
│   ├── build-proto.sh           # 单语言编译脚本（Go）
│   └── build-proto-multi-lang.sh # ⭐ 多语言编译脚本
├── gen.config.yaml              # 多语言配置文件
└── Makefile                     # 构建工具集成
```

## 🎯 核心特性

### 1. 一次定义，多处使用
- ✅ 单一的 proto 定义文件
- ✅ 自动生成多种语言的代码
- ✅ 保证跨语言的接口一致性

### 2. 灵活的语言支持
- ✅ 按需启用/禁用特定语言
- ✅ 独立的语言目录
- ✅ 语言特定的配置选项

### 3. 简单易用
```bash
# 生成 Go 代码
make build-go

# 生成 Python 代码  
make build-py

# 生成所有语言
make build-all

# 清理指定语言
make clean-py
```

### 4. 完善的工具链
- ✅ 自动检测依赖
- ✅ 友好的错误提示
- ✅ 代码格式化
- ✅ 统计信息展示

## 📁 目录结构设计

### Go 代码结构
```
gen/go/
├── common/
│   ├── common.pb.go
│   └── error.pb.go
└── adhoc/
    └── v1/
        ├── adhoc.pb.go
        └── adhoc_grpc.pb.go
```

**特点**:
- 完全保留 proto 的目录结构
- 使用 `source_relative` 路径
- 包路径: `youlingserv/gen/go/xxx`

### Python 代码结构
```
gen/python/
├── common/
│   ├── __init__.py
│   ├── common_pb2.py
│   ├── common_pb2.pyi
│   ├── error_pb2.py
│   └── error_pb2.pyi
└── adhoc/
    └── v1/
        ├── __init__.py
        ├── adhoc_pb2.py
        ├── adhoc_pb2.pyi
        ├── adhoc_pb2_grpc.py
        └── adhoc_pb2_grpc.pyi
```

**特点**:
- 自动生成 `__init__.py`
- 包含类型提示文件 `.pyi`
- 支持 gRPC 和 protobuf

### TypeScript 代码结构
```
gen/typescript/
├── common/
│   ├── common.ts
│   ├── common.d.ts
│   └── error.ts
└── adhoc/
    └── v1/
        └── adhoc.ts
```

**特点**:
- ES6 模块格式
- 包含类型定义
- Web 和 Node.js 兼容

## 🛠️ 使用方式

### Makefile 命令

| 命令 | 说明 |
|------|------|
| `make build` | 编译 Go 代码（默认） |
| `make build-go` | 编译 Go 代码 |
| `make build-py` | 编译 Python 代码 |
| `make build-ts` | 编译 TypeScript 代码 |
| `make build-all` | 编译所有语言 |
| `make build-multi LANGS="go python"` | 编译指定语言 |
| `make clean-go` | 清理 Go 代码 |
| `make clean-all` | 清理所有语言 |
| `make docs` | 生成 API 文档 |
| `make stats` | 显示统计信息 |

### 脚本命令

```bash
# 查看帮助
./scripts/build-proto-multi-lang.sh --help

# 生成 Go 和 Python
./scripts/build-proto-multi-lang.sh go python

# 生成所有语言
./scripts/build-proto-multi-lang.sh --all

# 检查依赖
./scripts/build-proto-multi-lang.sh --check

# 清理 Go 代码
./scripts/build-proto-multi-lang.sh --clean go

# 清理所有代码
./scripts/build-proto-multi-lang.sh --clean --all

# 生成文档
./scripts/build-proto-multi-lang.sh --docs

# 显示统计
./scripts/build-proto-multi-lang.sh --stats
```

## 🔧 配置管理

### gen.config.yaml

```yaml
languages:
  go:
    enabled: true           # 启用 Go
    output_dir: "gen/go"
    
  python:
    enabled: true           # 启用 Python
    output_dir: "gen/python"
    
  typescript:
    enabled: true           # 启用 TypeScript
    output_dir: "gen/typescript"
    
  java:
    enabled: false          # 禁用 Java
```

## 📦 包发布策略

### Go
```bash
# 作为 Go module
go get github.com/youlingserv/proto/gen/go
```

### Python
```bash
# 作为 Python package
pip install youlingserv-proto
```

### TypeScript
```bash
# 作为 npm package
npm install @youlingserv/proto
```

### Java
```xml
<!-- Maven -->
<dependency>
    <groupId>com.youlingserv</groupId>
    <artifactId>proto-gen</artifactId>
    <version>1.0.0</version>
</dependency>
```

## ✅ 最佳实践

### 1. 版本控制策略

**推荐提交**:
- ✅ Go 代码（依赖管理方便）
- ✅ Proto 定义文件（必须）

**可选提交**:
- ⚠️ Python/TypeScript（根据团队规范）

**不推荐提交**:
- ❌ Java/Kotlin（Maven/Gradle 管理）
- ❌ Rust（Cargo 管理）

### 2. CI/CD 集成

```yaml
# .github/workflows/proto.yml
- name: Generate all languages
  run: |
    make install
    make build-all
    
- name: Verify Go code
  run: |
    go build ./gen/go/...
    go test ./gen/go/...
```

### 3. 开发工作流

```bash
# 1. 修改 proto 文件
vim api/common/common.proto

# 2. 重新生成所有语言
make build-all

# 3. 验证生成的代码
make test

# 4. 提交更改
git add api/ gen/go/
git commit -m "feat: update proto definitions"
```

## 🚀 性能优化

### 并行编译
脚本自动并行处理多个 proto 文件

### 增量编译
只重新编译修改过的文件（计划中）

### 缓存机制
复用之前的编译结果（计划中）

## 📈 扩展性

### 添加新语言

1. 在 `gen.config.yaml` 中添加配置
2. 在脚本中添加 `generate_xxx()` 函数
3. 在 Makefile 中添加构建目标

示例：添加 PHP 支持

```bash
generate_php() {
    log_section "生成 PHP 代码"
    local output_dir="${OUTPUT_BASE}/php"
    mkdir -p "$output_dir"
    
    protoc \
        --proto_path="$PROTO_DIR" \
        --php_out="$output_dir" \
        --grpc_out="$output_dir" \
        --plugin=protoc-gen-grpc=/usr/local/bin/grpc_php_plugin \
        $(find "$PROTO_DIR" -name "*.proto")
}
```

## 🎓 学习资源

- [Protocol Buffers Language Guide](https://developers.google.com/protocol-buffers/docs/proto3)
- [gRPC 多语言教程](https://grpc.io/docs/languages/)
- [本项目架构文档](./MULTI_LANGUAGE_CODEGEN.md)
- [使用指南](./PROTO_MULTI_LANGUAGE_GUIDE.md)

## 📊 当前状态

| 语言 | 状态 | 优先级 |
|------|------|--------|
| Go | ✅ 完成 | P0 |
| Python | ✅ 完成 | P0 |
| TypeScript | ✅ 完成 | P1 |
| Java | 🔧 待完善 | P2 |
| C++ | 🔧 待完善 | P2 |
| Rust | 🔧 待完善 | P3 |
| Swift | 📋 计划中 | P3 |
| Kotlin | 📋 计划中 | P3 |
| Dart | 📋 计划中 | P3 |

## 🤝 贡献指南

欢迎贡献新的语言支持！

步骤：
1. Fork 项目
2. 添加新语言的生成函数
3. 更新文档
4. 提交 Pull Request

## 📝 更新日志

### v1.0.0 (2025-11-19)
- ✨ 初始版本
- ✅ 支持 Go、Python、TypeScript
- ✅ 多语言配置文件
- ✅ Makefile 集成
- ✅ 完善的文档

## 总结

通过这套多语言代码生成架构，我们实现了：

1. **统一的数据定义** - 单一的 proto 文件
2. **多语言支持** - 一键生成多种语言
3. **灵活配置** - 按需启用语言
4. **简单易用** - 友好的命令行工具
5. **可扩展** - 轻松添加新语言

这为跨语言、跨平台的项目开发提供了坚实的基础！ 🚀