# 多语言代码生成架构设计

## 目录结构设计

### 推荐结构（按语言分离）

```
gen/
├── go/                    # Go 语言生成代码
│   ├── common/
│   │   ├── common.pb.go
│   │   └── error.pb.go
│   └── adhoc/
│       └── v1/
│           ├── adhoc.pb.go
│           └── adhoc_grpc.pb.go
├── python/                # Python 语言生成代码
│   ├── common/
│   │   ├── common_pb2.py
│   │   └── error_pb2.py
│   └── adhoc/
│       └── v1/
│           ├── adhoc_pb2.py
│           └── adhoc_pb2_grpc.py
├── java/                  # Java 语言生成代码
│   └── com/
│       └── impirrot/
│           ├── common/
│           │   ├── Common.java
│           │   └── Error.java
│           └── adhoc/
│               └── v1/
│                   └── Adhoc.java
├── typescript/            # TypeScript 语言生成代码
│   ├── common/
│   │   ├── common.ts
│   │   └── error.ts
│   └── adhoc/
│       └── v1/
│           └── adhoc.ts
├── cpp/                   # C++ 语言生成代码
│   ├── common/
│   │   ├── common.pb.h
│   │   ├── common.pb.cc
│   │   ├── error.pb.h
│   │   └── error.pb.cc
│   └── adhoc/
│       └── v1/
│           ├── adhoc.pb.h
│           ├── adhoc.pb.cc
│           ├── adhoc.grpc.pb.h
│           └── adhoc.grpc.pb.cc
├── rust/                  # Rust 语言生成代码
│   ├── common/
│   │   ├── common.rs
│   │   └── error.rs
│   └── adhoc/
│       └── v1/
│           └── adhoc.rs
├── swift/                 # Swift 语言生成代码（iOS）
│   ├── common/
│   └── adhoc/
├── kotlin/                # Kotlin 语言生成代码（Android）
│   └── com/
│       └── impirrot/
└── dart/                  # Dart 语言生成代码（Flutter）
    ├── common/
    └── adhoc/
```

## 配置文件设计

### gen.config.yaml

```yaml
# 多语言代码生成配置文件
version: "1.0"

# 全局配置
global:
  proto_dir: "api"
  output_base: "gen"
  proto_path: ["api", "third_party"]  # proto 文件搜索路径

# 语言配置
languages:
  # Go 语言配置
  go:
    enabled: true
    output_dir: "gen/go"
    package_prefix: "impirrot/gen/go"
    options:
      paths: "source_relative"
      plugins:
        - protoc-gen-go
        - protoc-gen-go-grpc
    extra_args:
      - "--go_opt=Mcommon/common.proto=impirrot/gen/go/common"
  
  # Python 语言配置
  python:
    enabled: true
    output_dir: "gen/python"
    options:
      pyi_out: true  # 生成 type stubs
      plugins:
        - protoc-gen-python
        - protoc-gen-grpc-python
    extra_args:
      - "--python_out=gen/python"
      - "--grpc_python_out=gen/python"
  
  # Java 语言配置
  java:
    enabled: false  # 默认关闭
    output_dir: "gen/java"
    package: "com.impirrot"
    options:
      multiple_files: true
      plugins:
        - protoc-gen-java
        - protoc-gen-grpc-java
  
  # TypeScript 语言配置
  typescript:
    enabled: true
    output_dir: "gen/typescript"
    options:
      plugins:
        - protoc-gen-ts
        - protoc-gen-grpc-web
    extra_args:
      - "--ts_opt=esModuleInterop=true"
  
  # C++ 语言配置
  cpp:
    enabled: false
    output_dir: "gen/cpp"
    options:
      plugins:
        - protoc-gen-cpp
        - protoc-gen-grpc-cpp
  
  # Rust 语言配置
  rust:
    enabled: false
    output_dir: "gen/rust"
    options:
      plugins:
        - protoc-gen-rust
        - protoc-gen-tonic
  
  # Swift 语言配置
  swift:
    enabled: false
    output_dir: "gen/swift"
    options:
      plugins:
        - protoc-gen-swift
        - protoc-gen-grpc-swift
  
  # Kotlin 语言配置
  kotlin:
    enabled: false
    output_dir: "gen/kotlin"
    package: "com.impirrot"
    options:
      plugins:
        - protoc-gen-kotlin
        - protoc-gen-grpc-kotlin
  
  # Dart 语言配置（Flutter）
  dart:
    enabled: false
    output_dir: "gen/dart"
    options:
      plugins:
        - protoc-gen-dart

# 自定义插件配置
custom_plugins:
  - name: "openapi"
    enabled: false
    output_dir: "gen/openapi"
    command: "protoc-gen-openapiv2"
  
  - name: "doc"
    enabled: false
    output_dir: "docs/api"
    command: "protoc-gen-doc"
    args: ["--doc_opt=html,index.html"]

# 后处理脚本
post_process:
  - language: "go"
    commands:
      - "gofmt -w gen/go"
      - "goimports -w gen/go"
  
  - language: "python"
    commands:
      - "black gen/python"
      - "isort gen/python"
  
  - language: "typescript"
    commands:
      - "prettier --write gen/typescript/**/*.ts"
```

## 优势

1. **清晰的语言隔离**: 每种语言的代码在独立目录
2. **灵活配置**: 可以按需启用/禁用某种语言
3. **版本控制友好**: 可以选择性地提交某些语言的代码
4. **CI/CD 友好**: 可以并行编译不同语言
5. **包管理**: 每种语言可以作为独立的包发布

## 使用场景

- **Go**: 服务端开发
- **Python**: 数据处理、AI/ML、脚本
- **Java/Kotlin**: Android 客户端、企业级服务
- **TypeScript**: Web 前端、Node.js 服务
- **Swift**: iOS 客户端
- **Dart**: Flutter 跨平台应用
- **C++**: 高性能计算、嵌入式
- **Rust**: 高性能、安全关键型应用

## 版本发布策略

每种语言可以独立打包和发布：

```
# Go
go get github.com/impirrot/proto-gen/go

# Python
pip install impirrot-proto

# TypeScript
npm install @impirrot/proto-gen

# Java
maven: com.impirrot:proto-gen

# Dart
pub get impirrot_proto
```
