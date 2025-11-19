# 多语言代码生成使用指南

本项目支持从 Protocol Buffers 定义文件生成多种编程语言的客户端/服务端代码。

## 目录结构

```
gen/
├── go/                    # Go 语言生成代码
├── python/                # Python 语言生成代码
├── typescript/            # TypeScript 语言生成代码
├── java/                  # Java 语言生成代码
├── cpp/                   # C++ 语言生成代码
├── rust/                  # Rust 语言生成代码
└── ...                    # 其他语言
```

## 快速开始

### 1. 生成 Go 代码（默认）

```bash
make build
# 或
make build-go
```

### 2. 生成 Python 代码

```bash
# 先安装 Python gRPC 工具
pip install grpcio-tools

# 生成代码
make build-py
```

### 3. 生成 TypeScript 代码

```bash
# 先安装 TypeScript 插件
npm install -g ts-protoc-gen

# 生成代码
make build-ts
```

### 4. 生成所有语言

```bash
make build-all
```

### 5. 生成指定语言

```bash
make build-multi LANGS="go python typescript"
```

## 清理操作

```bash
# 清理 Go 代码
make clean-go

# 清理 Python 代码
make clean-py

# 清理所有语言
make clean-all
```

## 工具安装

### Go

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

### Python

```bash
pip install grpcio-tools
```

### TypeScript

```bash
npm install -g ts-protoc-gen
npm install -g grpc-tools
```

### Java

Java 插件通常包含在 protoc 中，无需额外安装。

### C++

```bash
# macOS
brew install grpc

# Ubuntu
sudo apt-get install -y libgrpc++-dev protobuf-compiler-grpc
```

### Rust

在 Cargo.toml 中添加：

```toml
[dependencies]
prost = "0.12"
tonic = "0.10"

[build-dependencies]
tonic-build = "0.10"
```

## 高级用法

### 使用脚本直接生成

```bash
# 生成 Go 和 Python
./scripts/build-proto-multi-lang.sh go python

# 生成所有语言
./scripts/build-proto-multi-lang.sh --all

# 查看帮助
./scripts/build-proto-multi-lang.sh --help
```

### 生成 API 文档

```bash
# 安装文档生成工具
go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest

# 生成文档
make docs
```

### 查看统计信息

```bash
make stats
```

## 配置文件

编辑 `gen.config.yaml` 来自定义生成配置：

```yaml
# 启用/禁用特定语言
languages:
  go:
    enabled: true
  python:
    enabled: true
  typescript:
    enabled: false
```

## 在代码中使用生成的文件

### Go

```go
import (
    "your-module/gen/go/common"
    adhocv1 "your-module/gen/go/adhoc/v1"
)

func example() {
    req := &adhocv1.HelloRequest{
        Name: "World",
    }
}
```

### Python

```python
from gen.python.common import common_pb2
from gen.python.adhoc.v1 import adhoc_pb2

req = adhoc_pb2.HelloRequest(name="World")
```

### TypeScript

```typescript
import { HelloRequest } from './gen/typescript/adhoc/v1/adhoc';

const req: HelloRequest = {
    name: 'World'
};
```

## CI/CD 集成

在 CI/CD 流程中自动生成代码：

```yaml
# GitHub Actions 示例
- name: Generate proto code
  run: |
    make install
    make build-all
```

## 常见问题

### Q: 如何添加新的语言支持？

A: 编辑 `scripts/build-proto-multi-lang.sh`，添加新的 `generate_xxx()` 函数。

### Q: 生成的代码可以提交到 Git 吗？

A: 推荐做法：
- Go 代码：提交（方便依赖管理）
- 其他语言：根据项目需求决定

### Q: 如何自定义生成选项？

A: 修改 `gen.config.yaml` 或在脚本中添加自定义参数。

## 语言特定说明

### Go
- 生成位置: `gen/go/`
- 包路径: 在 proto 文件的 `go_package` 选项中指定
- 导入: 直接使用 Go import

### Python
- 生成位置: `gen/python/`
- 包结构: 自动生成 `__init__.py`
- 导入: 使用相对路径 `from gen.python.xxx import xxx_pb2`

### TypeScript
- 生成位置: `gen/typescript/`
- 模块系统: ES6 modules
- 导入: 使用相对路径或配置路径映射

### Java
- 生成位置: `gen/java/`
- 包结构: 遵循 Java 包命名规范
- 导入: Maven/Gradle 依赖

## 性能优化

### 并行生成

```bash
# 使用 GNU parallel
ls api/**/*.proto | parallel -j4 protoc ...
```

### 增量编译

脚本会自动检测文件变化，只重新编译修改过的文件。

## 参考资料

- [Protocol Buffers 官方文档](https://developers.google.com/protocol-buffers)
- [gRPC 多语言教程](https://grpc.io/docs/languages/)
- [项目架构文档](./MULTI_LANGUAGE_CODEGEN.md)