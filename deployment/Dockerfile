# 多阶段构建 Dockerfile
# ==========================================
# 阶段 1: 构建阶段
# ==========================================
FROM golang:1.24-alpine AS builder

# 设置工作目录
WORKDIR /build

# 安装构建依赖
RUN apk add --no-cache git make

# 复制 go mod 文件
COPY go.mod go.sum ./

# 下载依赖（利用 Docker 缓存层）
RUN go mod download

# 复制源码
COPY . .

# 构建应用（启用 CGO_ENABLED=0 以生成静态二进制文件）
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o /build/adhoc-server \
    ./cmd/adhoc-server

# ==========================================
# 阶段 2: 运行阶段
# ==========================================
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache \
    ca-certificates \
    tzdata

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建非 root 用户
RUN addgroup -g 1000 youlingserv && \
    adduser -D -u 1000 -G youlingserv youlingserv

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /build/adhoc-server /app/adhoc-server

# 复制配置文件
COPY config.yml /app/config.yml

# 修改文件所有者
RUN chown -R youlingserv:youlingserv /app

# 切换到非 root 用户
USER youlingserv

# 暴露端口
EXPOSE 50051

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["sh", "-c", "nc -z localhost 50051 || exit 1"]

# 启动应用
# ENTRYPOINT ["/app/adhoc-server"]
CMD [ "/app/adhoc-server" ]
