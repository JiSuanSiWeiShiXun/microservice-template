package main

import (
	"youlingserv/internal/api/handler"
	"youlingserv/internal/shared/auth"
)

// APIComponents 聚合 API 服务的所有组件
type APIComponents struct {
	HelloHandler      handler.HelloHandlerInterface
	PermissionChecker *auth.PermissionChecker
}

// NewAPIComponents 创建 API 组件聚合
func NewAPIComponents(
	helloHandler handler.HelloHandlerInterface,
	permissionChecker *auth.PermissionChecker,
) *APIComponents {
	return &APIComponents{
		HelloHandler:      helloHandler,
		PermissionChecker: permissionChecker,
	}
}
