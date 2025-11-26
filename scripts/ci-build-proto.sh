#!/bin/bash

# CI/CD Proto 编译脚本
# 适用于持续集成环境，包含更严格的验证

set -euo pipefail  # 严格模式

# 环境变量
CI_MODE=${CI_MODE:-false}
FAIL_ON_DIFF=${FAIL_ON_DIFF:-true}
GENERATE_DOCS=${GENERATE_DOCS:-false}

# 颜色定义
if [[ "${CI_MODE}" == "true" ]]; then
    # CI 环境不使用颜色
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    NC=""
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Git 状态
check_git_status() {
    log "检查 Git 状态..."
    
    if ! git status --porcelain | grep -q "^??"; then
        log "Git 工作目录干净"
    else
        log_warning "Git 工作目录有未跟踪的文件"
    fi
}

# 安装依赖
install_dependencies() {
    log "安装编译依赖..."
    
    # 检查 Go 环境
    if ! command -v go &> /dev/null; then
        log_error "Go 未安装"
        exit 1
    fi
    
    # 安装 protoc 插件
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
    
    # 可选：安装其他插件
    if [[ "${GENERATE_DOCS}" == "true" ]]; then
        go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest
    fi
    
    log_success "依赖安装完成"
}

# 编译前备份
backup_existing() {
    if [[ -d "gen" ]]; then
        log "备份现有生成文件..."
        cp -r gen gen.backup
    fi
}

# 恢复备份
restore_backup() {
    if [[ -d "gen.backup" ]]; then
        log "恢复备份文件..."
        rm -rf gen
        mv gen.backup gen
    fi
}

# 清理备份
cleanup_backup() {
    if [[ -d "gen.backup" ]]; then
        rm -rf gen.backup
    fi
}

# 编译 proto 文件
compile_protos() {
    log "编译 Proto 文件..."
    
    # 使用主编译脚本
    if [[ -x "scripts/build-proto.sh" ]]; then
        scripts/build-proto.sh --clean
    else
        log_error "编译脚本不存在或不可执行"
        exit 1
    fi
    
    log_success "Proto 编译完成"
}

# 验证生成的代码
validate_generated_code() {
    log "验证生成的代码..."
    
    # 检查是否有生成文件
    if [[ ! -d "gen" ]] || [[ -z "$(find gen -name '*.go' 2>/dev/null)" ]]; then
        log_error "未找到生成的 Go 文件"
        exit 1
    fi
    
    # Go 格式化检查
    log "检查 Go 代码格式..."
    if ! gofmt -l gen/ | grep -q .; then
        log_success "Go 代码格式正确"
    else
        log_error "Go 代码格式不正确"
        gofmt -l gen/
        exit 1
    fi
    
    # Go 编译检查
    log "检查 Go 代码编译..."
    if go build ./gen/...; then
        log_success "Go 代码编译通过"
    else
        log_error "Go 代码编译失败"
        exit 1
    fi
    
    # Go vet 检查
    log "运行 go vet..."
    if go vet ./gen/...; then
        log_success "go vet 检查通过"
    else
        log_error "go vet 检查失败"
        exit 1
    fi
}

# 检查生成文件的差异
check_diff() {
    if [[ "${FAIL_ON_DIFF}" != "true" ]]; then
        log "跳过差异检查"
        return 0
    fi
    
    log "检查生成文件的差异..."
    
    if [[ -d "gen.backup" ]]; then
        if diff -r gen.backup gen > /dev/null; then
            log_success "生成的文件没有变化"
        else
            log_warning "生成的文件有变化:"
            diff -r gen.backup gen || true
            
            if [[ "${CI_MODE}" == "true" ]]; then
                log_error "CI 模式下检测到文件变化，请确保提交最新的生成文件"
                exit 1
            fi
        fi
    fi
}

# 生成文档
generate_docs() {
    if [[ "${GENERATE_DOCS}" != "true" ]]; then
        return 0
    fi
    
    log "生成 API 文档..."
    
    mkdir -p docs/api
    
    find api -name "*.proto" -exec protoc \
        --proto_path=api \
        --doc_out=docs/api \
        --doc_opt=html,index.html \
        {} +
    
    log_success "API 文档生成完成"
}

# 清理函数
cleanup() {
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        log_error "脚本执行失败，清理中..."
        restore_backup
    fi
    
    cleanup_backup
    exit $exit_code
}

# 主函数
main() {
    # 设置清理陷阱
    trap cleanup EXIT
    
    log "开始 CI/CD Proto 编译流程..."
    log "CI_MODE: ${CI_MODE}"
    log "FAIL_ON_DIFF: ${FAIL_ON_DIFF}"
    log "GENERATE_DOCS: ${GENERATE_DOCS}"
    
    check_git_status
    install_dependencies
    backup_existing
    compile_protos
    validate_generated_code
    check_diff
    generate_docs
    
    log_success "所有检查通过！✅"
}

# 运行主函数
main "$@"