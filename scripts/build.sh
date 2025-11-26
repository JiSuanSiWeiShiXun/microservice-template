#!/bin/bash

# 构建 RPC 服务器
echo "Building RPC server..."
go build -o bin/rpc-server ./cmd/rpc-server

# 构建 HTTP 网关
echo "Building HTTP gateway..."
go build -o bin/http-gateway ./cmd/http-gateway

echo "Build completed!"
echo "Binaries are in bin/ directory"
