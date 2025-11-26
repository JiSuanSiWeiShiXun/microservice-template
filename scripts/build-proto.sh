#!/bin/bash

# Proto 编译脚本
# 自动发现并编译所有 .proto 文件，保持目录结构一致

set -e  # 遇到错误立即退出

# 配置变量
PROTO_DIR="api"
OUTPUT_DIR="gen"
PROTO_PATH="api"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    if ! command -v protoc &> /dev/null; then
        log_error "protoc 未安装，请先安装 Protocol Buffers"
        exit 1
    fi
    
    if ! protoc --version | grep -q "libprotoc"; then
        log_error "protoc 版本信息异常"
        exit 1
    fi
    
    log_info "protoc 版本: $(protoc --version)"
}

# 清理输出目录
clean_output() {
    if [ "$1" = "--clean" ]; then
        log_info "清理输出目录: $OUTPUT_DIR"
        rm -rf "$OUTPUT_DIR"
    fi
    
    # 确保输出目录存在
    mkdir -p "$OUTPUT_DIR"
}

# 查找所有 proto 文件
find_proto_files() {
    log_info "查找 proto 文件..."
    
    # 查找所有 .proto 文件
    PROTO_FILES=$(find "$PROTO_DIR" -name "*.proto" | sort)
    
    if [ -z "$PROTO_FILES" ]; then
        log_error "未找到任何 .proto 文件在目录: $PROTO_DIR"
        exit 1
    fi
    
    log_info "找到以下 proto 文件:"
    echo "$PROTO_FILES" | while read -r file; do
        echo "  - $file"
    done
    
    echo
}

# 编译 proto 文件
compile_protos() {
    log_info "开始编译 proto 文件..."
    
    # 将文件列表转为数组
    PROTO_ARRAY=($PROTO_FILES)
    
    # 构建 protoc 命令
    PROTOC_CMD="protoc"
    PROTOC_CMD="$PROTOC_CMD --proto_path=$PROTO_PATH"
    PROTOC_CMD="$PROTOC_CMD --go_out=$OUTPUT_DIR"
    PROTOC_CMD="$PROTOC_CMD --go_opt=paths=source_relative"
    PROTOC_CMD="$PROTOC_CMD --go-grpc_out=$OUTPUT_DIR"
    PROTOC_CMD="$PROTOC_CMD --go-grpc_opt=paths=source_relative"
    
    # 添加所有 proto 文件
    for proto_file in "${PROTO_ARRAY[@]}"; do
        # 转换为相对于 PROTO_PATH 的路径
        relative_path=$(echo "$proto_file" | sed "s|^$PROTO_PATH/||")
        PROTOC_CMD="$PROTOC_CMD $relative_path"
    done
    
    log_info "执行命令: $PROTOC_CMD"
    echo
    
    # 执行编译
    eval "$PROTOC_CMD"
    
    if [ $? -eq 0 ]; then
        log_info "编译成功！"
    else
        log_error "编译失败！"
        exit 1
    fi
}

# 显示生成的文件
show_generated_files() {
    log_info "生成的文件:"
    find "$OUTPUT_DIR" -name "*.go" | sort | while read -r file; do
        echo "  - $file"
    done
    echo
}

# 验证生成的文件
validate_generated() {
    log_info "验证生成的文件..."
    
    # 检查是否有 Go 文件生成
    GO_FILES=$(find "$OUTPUT_DIR" -name "*.go" | wc -l)
    
    if [ "$GO_FILES" -eq 0 ]; then
        log_error "未生成任何 Go 文件"
        exit 1
    fi
    
    log_info "成功生成 $GO_FILES 个 Go 文件"
}

# 显示帮助信息
show_help() {
    echo "Proto 编译脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --clean     编译前清理输出目录"
    echo "  --watch     监控模式（开发中）"
    echo "  --help      显示此帮助信息"
    echo ""
    echo "环境变量:"
    echo "  PROTO_DIR   proto 文件目录 (默认: api)"
    echo "  OUTPUT_DIR  输出目录 (默认: gen)"
    echo "  PROTO_PATH  proto 搜索路径 (默认: api)"
    echo ""
    echo "示例:"
    echo "  $0 --clean    # 清理并编译"
    echo "  PROTO_DIR=protos $0  # 使用自定义目录"
}

# 主函数
main() {
    echo "================================"
    echo "     Proto 编译脚本 v1.0"
    echo "================================"
    echo
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                CLEAN_FLAG="--clean"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            --watch)
                log_warn "监控模式尚未实现"
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查当前目录
    if [ ! -d "$PROTO_DIR" ]; then
        log_error "Proto 目录不存在: $PROTO_DIR"
        log_info "请在项目根目录运行此脚本"
        exit 1
    fi
    
    # 执行编译流程
    check_dependencies
    clean_output "$CLEAN_FLAG"
    find_proto_files
    compile_protos
    validate_generated
    show_generated_files
    
    log_info "编译完成！✨"
}

# 运行主函数
main "$@"