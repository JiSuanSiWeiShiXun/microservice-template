#!/bin/bash

# 多语言 Proto 代码生成脚本
set -e

# 配置文件路径
CONFIG_FILE="${CONFIG_FILE:-gen.config.yaml}"
PROTO_DIR="${PROTO_DIR:-api}"
OUTPUT_BASE="${OUTPUT_BASE:-gen}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 检查工具是否安装
check_tool() {
    if command -v "$1" &> /dev/null; then
        log_info "✓ $1 已安装"
        return 0
    else
        log_warn "✗ $1 未安装"
        return 1
    fi
}

# 检查必要的工具
check_dependencies() {
    log_section "检查依赖工具"
    
    local all_good=true
    
    if ! check_tool "protoc"; then
        log_error "protoc 是必需的"
        all_good=false
    fi
    
    echo ""
    
    if [ "$all_good" = false ]; then
        log_error "请先安装必要的工具"
        exit 1
    fi
}

# 编译 Go 代码
generate_go() {
    log_section "生成 Go 代码"
    
    local output_dir="${OUTPUT_BASE}/go"
    mkdir -p "$output_dir"
    
    if ! check_tool "protoc-gen-go" || ! check_tool "protoc-gen-go-grpc"; then
        log_warn "Go 插件未安装，跳过 Go 代码生成"
        log_info "安装方法:"
        echo "  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
        echo "  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
        return
    fi
    
    log_info "编译 Go 代码到 $output_dir..."
    
    find "$PROTO_DIR" -name "*.proto" | while read -r proto_file; do
        log_info "  处理: $proto_file"
    done
    
    protoc \
        --proto_path="$PROTO_DIR" \
        --go_out="$output_dir" \
        --go_opt=paths=source_relative \
        --go-grpc_out="$output_dir" \
        --go-grpc_opt=paths=source_relative \
        $(find "$PROTO_DIR" -name "*.proto")
    
    log_info "✓ Go 代码生成完成"
    
    # 后处理
    if check_tool "gofmt"; then
        log_info "格式化 Go 代码..."
        gofmt -w "$output_dir" 2>/dev/null || true
    fi
    
    if check_tool "goimports"; then
        log_info "优化 Go imports..."
        goimports -w "$output_dir" 2>/dev/null || true
    fi
    
    echo ""
}

# 编译 Python 代码
generate_python() {
    log_section "生成 Python 代码"
    
    local output_dir="${OUTPUT_BASE}/python"
    mkdir -p "$output_dir"
    
    if ! check_tool "grpc_tools.protoc" && ! python3 -c "import grpc_tools" 2>/dev/null; then
        log_warn "Python gRPC 工具未安装，跳过 Python 代码生成"
        log_info "安装方法:"
        echo "  pip install grpcio-tools"
        return
    fi
    
    log_info "编译 Python 代码到 $output_dir..."
    
    python3 -m grpc_tools.protoc \
        --proto_path="$PROTO_DIR" \
        --python_out="$output_dir" \
        --grpc_python_out="$output_dir" \
        --pyi_out="$output_dir" \
        $(find "$PROTO_DIR" -name "*.proto")
    
    # 创建 __init__.py 文件
    find "$output_dir" -type d -exec touch {}/__init__.py \;
    
    log_info "✓ Python 代码生成完成"
    
    # 后处理
    if check_tool "black"; then
        log_info "格式化 Python 代码..."
        black "$output_dir" 2>/dev/null || true
    fi
    
    echo ""
}

# 编译 TypeScript 代码
generate_typescript() {
    log_section "生成 TypeScript 代码"
    
    local output_dir="${OUTPUT_BASE}/typescript"
    mkdir -p "$output_dir"
    
    if ! check_tool "protoc-gen-ts"; then
        log_warn "TypeScript 插件未安装，跳过 TypeScript 代码生成"
        log_info "安装方法:"
        echo "  npm install -g ts-protoc-gen"
        return
    fi
    
    log_info "编译 TypeScript 代码到 $output_dir..."
    
    protoc \
        --proto_path="$PROTO_DIR" \
        --plugin=protoc-gen-ts=$(which protoc-gen-ts) \
        --ts_out="$output_dir" \
        $(find "$PROTO_DIR" -name "*.proto")
    
    log_info "✓ TypeScript 代码生成完成"
    
    # 后处理
    if check_tool "prettier"; then
        log_info "格式化 TypeScript 代码..."
        prettier --write "$output_dir/**/*.ts" 2>/dev/null || true
    fi
    
    echo ""
}

# 编译 Java 代码
generate_java() {
    log_section "生成 Java 代码"
    
    local output_dir="${OUTPUT_BASE}/java"
    mkdir -p "$output_dir"
    
    log_info "编译 Java 代码到 $output_dir..."
    
    protoc \
        --proto_path="$PROTO_DIR" \
        --java_out="$output_dir" \
        $(find "$PROTO_DIR" -name "*.proto")
    
    log_info "✓ Java 代码生成完成"
    echo ""
}

# 编译 C++ 代码
generate_cpp() {
    log_section "生成 C++ 代码"
    
    local output_dir="${OUTPUT_BASE}/cpp"
    mkdir -p "$output_dir"
    
    if ! check_tool "grpc_cpp_plugin"; then
        log_warn "C++ gRPC 插件未安装，跳过 C++ 代码生成"
        return
    fi
    
    log_info "编译 C++ 代码到 $output_dir..."
    
    protoc \
        --proto_path="$PROTO_DIR" \
        --cpp_out="$output_dir" \
        --grpc_out="$output_dir" \
        --plugin=protoc-gen-grpc=$(which grpc_cpp_plugin) \
        $(find "$PROTO_DIR" -name "*.proto")
    
    log_info "✓ C++ 代码生成完成"
    echo ""
}

# 编译 Rust 代码
generate_rust() {
    log_section "生成 Rust 代码"
    
    local output_dir="${OUTPUT_BASE}/rust"
    mkdir -p "$output_dir"
    
    log_warn "Rust 代码生成需要 prost 或 tonic，请参考文档手动配置"
    echo ""
}

# 生成文档
generate_docs() {
    log_section "生成 API 文档"
    
    local output_dir="docs/api"
    mkdir -p "$output_dir"
    
    if ! check_tool "protoc-gen-doc"; then
        log_warn "protoc-gen-doc 未安装，跳过文档生成"
        log_info "安装方法:"
        echo "  go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest"
        return
    fi
    
    log_info "生成 API 文档到 $output_dir..."
    
    protoc \
        --proto_path="$PROTO_DIR" \
        --doc_out="$output_dir" \
        --doc_opt=html,index.html \
        $(find "$PROTO_DIR" -name "*.proto")
    
    log_info "✓ API 文档生成完成"
    echo ""
}

# 显示统计信息
show_stats() {
    log_section "生成统计"
    
    echo "Proto 文件:"
    find "$PROTO_DIR" -name "*.proto" | wc -l | xargs echo "  总计:"
    
    echo ""
    echo "生成的代码文件:"
    
    for lang in go python typescript java cpp rust; do
        local dir="${OUTPUT_BASE}/${lang}"
        if [ -d "$dir" ]; then
            local count=$(find "$dir" -type f | wc -l | xargs)
            if [ "$count" -gt 0 ]; then
                echo "  ${lang}: ${count} 个文件"
            fi
        fi
    done
    
    echo ""
}

# 清理生成的代码
clean_generated() {
    log_section "清理生成的代码"
    
    if [ "$1" = "--all" ]; then
        log_warn "删除所有生成的代码..."
        rm -rf "${OUTPUT_BASE}"
        log_info "✓ 清理完成"
    else
        log_info "清理指定语言: $1"
        rm -rf "${OUTPUT_BASE}/$1"
        log_info "✓ $1 代码已清理"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
多语言 Proto 代码生成工具

用法: $0 [选项] [语言...]

选项:
  --all              生成所有语言的代码
  --clean [lang]     清理生成的代码（不指定语言则清理全部）
  --check            只检查依赖，不生成代码
  --docs             生成 API 文档
  --stats            显示统计信息
  --help             显示此帮助信息

支持的语言:
  go                 生成 Go 代码
  python             生成 Python 代码
  typescript, ts     生成 TypeScript 代码
  java               生成 Java 代码
  cpp                生成 C++ 代码
  rust               生成 Rust 代码

示例:
  $0 --all           # 生成所有语言
  $0 go python       # 只生成 Go 和 Python
  $0 --clean go      # 清理 Go 代码
  $0 --clean --all   # 清理所有代码
  $0 --docs          # 生成文档

环境变量:
  PROTO_DIR          Proto 文件目录 (默认: api)
  OUTPUT_BASE        输出基础目录 (默认: gen)
  CONFIG_FILE        配置文件路径 (默认: gen.config.yaml)
EOF
}

# 主函数
main() {
    echo ""
    log_section "多语言 Proto 代码生成工具 v1.0"
    echo ""
    
    # 解析参数
    local languages=()
    local generate_all=false
    local generate_docs_flag=false
    local show_stats_flag=false
    local clean_flag=false
    local clean_target=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                generate_all=true
                shift
                ;;
            --clean)
                clean_flag=true
                if [[ $2 == "--all" ]]; then
                    clean_target="--all"
                    shift 2
                elif [[ $2 != --* ]] && [[ -n $2 ]]; then
                    clean_target="$2"
                    shift 2
                else
                    clean_target="--all"
                    shift
                fi
                ;;
            --check)
                check_dependencies
                exit 0
                ;;
            --docs)
                generate_docs_flag=true
                shift
                ;;
            --stats)
                show_stats_flag=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            go|python|typescript|ts|java|cpp|rust)
                languages+=("$1")
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 处理清理
    if [ "$clean_flag" = true ]; then
        clean_generated "$clean_target"
        exit 0
    fi
    
    # 检查依赖
    check_dependencies
    
    # 如果指定了 --all 或没有指定语言，生成所有
    if [ "$generate_all" = true ] || [ ${#languages[@]} -eq 0 ]; then
        languages=(go python typescript)
    fi
    
    # 生成代码
    for lang in "${languages[@]}"; do
        case $lang in
            go)
                generate_go
                ;;
            python)
                generate_python
                ;;
            typescript|ts)
                generate_typescript
                ;;
            java)
                generate_java
                ;;
            cpp)
                generate_cpp
                ;;
            rust)
                generate_rust
                ;;
        esac
    done
    
    # 生成文档
    if [ "$generate_docs_flag" = true ]; then
        generate_docs
    fi
    
    # 显示统计
    if [ "$show_stats_flag" = true ] || [ "$generate_all" = true ]; then
        show_stats
    fi
    
    log_section "完成"
    log_info "所有代码生成完成！ ✨"
    echo ""
}

# 运行主函数
main "$@"