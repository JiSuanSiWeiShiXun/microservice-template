@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Proto 编译脚本
REM 自动发现并编译所有 .proto 文件，保持目录结构一致

REM 配置变量
set "PROTO_DIR=api"
set "OUTPUT_DIR=gen"
set "PROTO_PATH=api"

REM 临时文件
set "TEMP_FILES=%TEMP%\proto_files_%RANDOM%.txt"

REM 解析命令行参数
set "CLEAN_FLAG="
:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--clean" (
    set "CLEAN_FLAG=1"
    shift
    goto parse_args
)
if /I "%~1"=="--help" (
    call :show_help
    exit /b 0
)
if /I "%~1"=="--watch" (
    call :log_warn "监控模式尚未实现"
    shift
    goto parse_args
)
call :log_error "未知参数: %~1"
call :show_help
exit /b 1
:args_done

echo ================================
echo      Proto 编译脚本 v1.0
echo ================================
echo.

REM 检查当前目录
if not exist "%PROTO_DIR%" (
    call :log_error "Proto 目录不存在: %PROTO_DIR%"
    call :log_info "请在项目根目录运行此脚本"
    exit /b 1
)

REM 执行编译流程
call :check_dependencies
if errorlevel 1 exit /b 1

call :clean_output
if errorlevel 1 exit /b 1

call :find_proto_files
if errorlevel 1 exit /b 1

call :compile_protos
if errorlevel 1 exit /b 1

call :validate_generated
if errorlevel 1 exit /b 1

call :show_generated_files

call :log_info "编译完成！✨"
goto :cleanup

REM ==================== 函数定义 ====================

:log_info
echo [INFO] %~1
exit /b 0

:log_warn
echo [WARN] %~1
exit /b 0

:log_error
echo [ERROR] %~1
exit /b 0

:check_dependencies
call :log_info "检查依赖..."

where protoc >nul 2>&1
if errorlevel 1 (
    call :log_error "protoc 未安装，请先安装 Protocol Buffers"
    exit /b 1
)

for /f "delims=" %%i in ('protoc --version 2^>^&1') do set "PROTOC_VERSION=%%i"
call :log_info "protoc 版本: !PROTOC_VERSION!"
exit /b 0

:clean_output
if defined CLEAN_FLAG (
    call :log_info "清理输出目录: %OUTPUT_DIR%"
    if exist "%OUTPUT_DIR%" (
        rmdir /s /q "%OUTPUT_DIR%" 2>nul
    )
)

REM 确保输出目录存在
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
exit /b 0

:find_proto_files
call :log_info "查找 proto 文件..."

REM 查找所有 .proto 文件
if exist "%TEMP_FILES%" del "%TEMP_FILES%"
for /r "%PROTO_DIR%" %%f in (*.proto) do (
    echo %%f >> "%TEMP_FILES%"
)

if not exist "%TEMP_FILES%" (
    call :log_error "未找到任何 .proto 文件在目录: %PROTO_DIR%"
    exit /b 1
)

REM 检查文件是否为空
for %%A in ("%TEMP_FILES%") do set "FILE_SIZE=%%~zA"
if "!FILE_SIZE!"=="0" (
    call :log_error "未找到任何 .proto 文件在目录: %PROTO_DIR%"
    del "%TEMP_FILES%"
    exit /b 1
)

call :log_info "找到以下 proto 文件:"
for /f "usebackq delims=" %%f in ("%TEMP_FILES%") do (
    echo   - %%f
)
echo.
exit /b 0

:compile_protos
call :log_info "开始编译 proto 文件..."

REM 构建 protoc 命令
set "PROTOC_CMD=protoc"
set "PROTOC_CMD=!PROTOC_CMD! --proto_path=%PROTO_PATH%"
set "PROTOC_CMD=!PROTOC_CMD! --go_out=%OUTPUT_DIR%"
set "PROTOC_CMD=!PROTOC_CMD! --go_opt=paths=source_relative"
set "PROTOC_CMD=!PROTOC_CMD! --go-grpc_out=%OUTPUT_DIR%"
set "PROTOC_CMD=!PROTOC_CMD! --go-grpc_opt=paths=source_relative"

REM 添加所有 proto 文件（使用相对路径）
for /f "usebackq delims=" %%f in ("%TEMP_FILES%") do (
    set "FULL_PATH=%%f"
    REM 获取相对于当前目录的路径
    set "REL_PATH=!FULL_PATH:%CD%\=!"
    REM 转换反斜杠为正斜杠
    set "REL_PATH=!REL_PATH:\=/!"
    set "PROTOC_CMD=!PROTOC_CMD! !REL_PATH!"
)

call :log_info "执行命令: !PROTOC_CMD!"
echo.

REM 执行编译
!PROTOC_CMD!
if errorlevel 1 (
    call :log_error "编译失败！"
    exit /b 1
)

call :log_info "编译成功！"
exit /b 0

:show_generated_files
call :log_info "生成的文件:"
for /r "%OUTPUT_DIR%" %%f in (*.go) do (
    echo   - %%f
)
echo.
exit /b 0

:validate_generated
call :log_info "验证生成的文件..."

set "GO_FILE_COUNT=0"
for /r "%OUTPUT_DIR%" %%f in (*.go) do (
    set /a GO_FILE_COUNT+=1
)

if !GO_FILE_COUNT! equ 0 (
    call :log_error "未生成任何 Go 文件"
    exit /b 1
)

call :log_info "成功生成 !GO_FILE_COUNT! 个 Go 文件"
exit /b 0

:show_help
echo Proto 编译脚本
echo.
echo 用法: %~nx0 [选项]
echo.
echo 选项:
echo   --clean     编译前清理输出目录
echo   --watch     监控模式（开发中）
echo   --help      显示此帮助信息
echo.
echo 环境变量:
echo   PROTO_DIR   proto 文件目录 (默认: api^)
echo   OUTPUT_DIR  输出目录 (默认: gen^)
echo   PROTO_PATH  proto 搜索路径 (默认: api^)
echo.
echo 示例:
echo   %~nx0 --clean    # 清理并编译
echo   set PROTO_DIR=protos ^& %~nx0  # 使用自定义目录
exit /b 0

:cleanup
if exist "%TEMP_FILES%" del "%TEMP_FILES%"
endlocal
