# Makefile for Protocol Buffers compilation

# 配置变量
PROTO_DIR := api
OUTPUT_DIR := gen
OUTPUT_GO_DIR := gen/go
SCRIPT_DIR := scripts

# 检测操作系统
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    FIND_CMD := find $(PROTO_DIR) -name "*.proto" -type f
else
    FIND_CMD := find $(PROTO_DIR) -name "*.proto" -type f
endif

# 所有 proto 文件
PROTO_FILES := $(shell $(FIND_CMD))
# 生成的 Go 文件
GO_FILES := $(PROTO_FILES:$(PROTO_DIR)/%.proto=$(OUTPUT_GO_DIR)/%.pb.go)

# 默认目标
.PHONY: all
all: build

# 显示帮助信息
.PHONY: help
help:
	@echo "Protocol Buffers 多语言编译 Makefile"
	@echo ""
	@echo "单语言编译:"
	@echo "  build       编译 Go 代码（默认）"
	@echo "  build-go    编译 Go 代码"
	@echo "  build-py    编译 Python 代码"
	@echo "  build-ts    编译 TypeScript 代码"
	@echo "  build-java  编译 Java 代码"
	@echo ""
	@echo "多语言编译:"
	@echo "  build-all   编译所有语言"
	@echo "  build-multi LANGS=\"go python ts\"  编译指定语言"
	@echo ""
	@echo "清理操作:"
	@echo "  clean       清理 Go 生成的文件"
	@echo "  clean-all   清理所有语言生成的文件"
	@echo "  clean-go    清理 Go 代码"
	@echo "  clean-py    清理 Python 代码"
	@echo "  clean-ts    清理 TypeScript 代码"
	@echo ""
	@echo "其他操作:"
	@echo "  rebuild     清理并重新编译 Go"
	@echo "  list        列出所有 proto 文件"
	@echo "  check       检查依赖和环境"
	@echo "  watch       监控文件变化并自动编译"
	@echo "  install     安装编译依赖"
	@echo "  docs        生成 API 文档"
	@echo "  stats       显示生成统计"
	@echo "  help        显示此帮助信息"
	@echo ""
	@echo "变量:"
	@echo "  PROTO_DIR=$(PROTO_DIR)"
	@echo "  OUTPUT_DIR=$(OUTPUT_DIR)"

# 检查依赖
.PHONY: check
check:
	@echo "检查编译环境..."
	@command -v protoc >/dev/null 2>&1 || { echo "错误: protoc 未安装"; exit 1; }
	@command -v protoc-gen-go >/dev/null 2>&1 || { echo "错误: protoc-gen-go 未安装"; exit 1; }
	@command -v protoc-gen-go-grpc >/dev/null 2>&1 || { echo "错误: protoc-gen-go-grpc 未安装"; exit 1; }
	@echo "✅ 所有依赖已安装"
	@echo "protoc 版本: $$(protoc --version)"

# 安装依赖
.PHONY: install
install:
	@echo "安装 protoc 相关依赖..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@echo "✅ 依赖安装完成"

# 列出所有 proto 文件
.PHONY: list
list:
	@echo "发现的 proto 文件:"
	@for file in $(PROTO_FILES); do echo "  - $$file"; done
	@echo "总计: $(words $(PROTO_FILES)) 个文件"

# 清理生成的文件
.PHONY: clean
clean: clean-go

# 清理所有语言
.PHONY: clean-all
clean-all:
	@echo "清理所有生成的文件..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh --clean --all
	@echo "✅ 清理完成"

# 清理 Go 代码
.PHONY: clean-go
clean-go:
	@echo "清理 Go 生成的文件..."
	@rm -rf $(OUTPUT_GO_DIR)
	@echo "✅ Go 代码清理完成"

# 清理 Python 代码
.PHONY: clean-py
clean-py:
	@echo "清理 Python 生成的文件..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh --clean python

# 清理 TypeScript 代码
.PHONY: clean-ts
clean-ts:
	@echo "清理 TypeScript 生成的文件..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh --clean typescript

# 创建输出目录
$(OUTPUT_DIR):
	@mkdir -p $(OUTPUT_DIR)

# 编译 proto 文件 (使用脚本，默认 Go)
.PHONY: build
build: build-go

# 编译 Go 代码
.PHONY: build-go
build-go: check $(OUTPUT_DIR)
	@echo "编译 Go 代码..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh go

# 编译 Python 代码
.PHONY: build-py build-python
build-py build-python: $(OUTPUT_DIR)
	@echo "编译 Python 代码..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh python

# 编译 TypeScript 代码
.PHONY: build-ts build-typescript
build-ts build-typescript: $(OUTPUT_DIR)
	@echo "编译 TypeScript 代码..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh typescript

# 编译 Java 代码
.PHONY: build-java
build-java: $(OUTPUT_DIR)
	@echo "编译 Java 代码..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh java

# 编译所有语言
.PHONY: build-all
build-all: $(OUTPUT_DIR)
	@echo "编译所有语言的代码..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh --all

# 编译指定语言
.PHONY: build-multi
build-multi: $(OUTPUT_DIR)
	@echo "编译指定语言: $(LANGS)"
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh $(LANGS)

# 快速编译 (直接使用 protoc，适合简单项目)
.PHONY: build-simple
build-simple: check $(OUTPUT_DIR)
	@echo "直接编译 proto 文件..."
	@if [ -n "$(PROTO_FILES)" ]; then \
		protoc --proto_path=$(PROTO_DIR) \
			--go_out=$(OUTPUT_DIR) \
			--go_opt=paths=source_relative \
			--go-grpc_out=$(OUTPUT_DIR) \
			--go-grpc_opt=paths=source_relative \
			$(PROTO_FILES:$(PROTO_DIR)/%=%); \
		echo "✅ 编译完成"; \
	else \
		echo "未找到 proto 文件"; \
	fi

# 清理并重新编译
.PHONY: rebuild
rebuild: clean build

# 监控文件变化 (需要安装 fswatch)
.PHONY: watch
watch:
	@echo "监控 proto 文件变化..."
	@command -v fswatch >/dev/null 2>&1 || { echo "请先安装 fswatch: brew install fswatch"; exit 1; }
	@echo "监控目录: $(PROTO_DIR)"
	@echo "按 Ctrl+C 停止监控"
	@fswatch -o $(PROTO_DIR) | while read f; do \
		echo "检测到文件变化，重新编译..."; \
		make build-simple; \
		echo "编译完成，继续监控..."; \
	done

# 验证生成的代码
.PHONY: verify
verify: build
	@echo "验证生成的 Go 代码..."
	@find $(OUTPUT_DIR) -name "*.go" -exec go fmt {} \;
	@find $(OUTPUT_DIR) -name "*.go" -exec goimports -w {} \; 2>/dev/null || true
	@echo "✅ 代码验证完成"

# 显示生成文件统计
.PHONY: stats
stats:
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh --stats

# 生成 API 文档
.PHONY: docs
docs:
	@echo "生成 API 文档..."
	@$(SCRIPT_DIR)/build-proto-multi-lang.sh --docs

# 开发模式：清理、编译、验证
.PHONY: dev
dev: clean build verify stats