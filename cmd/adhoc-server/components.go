package main

import (
	"impirrot/internal/adhoc/service"
	"impirrot/internal/shared/auth"
)

// AdhocComponents 聚合 Adhoc 服务的所有组件
type AdhocComponents struct {
	ServiceImpl       service.AdhocServiceInterface
	PermissionChecker *auth.PermissionChecker
}

// NewAdhocComponents 创建 Adhoc 组件聚合
func NewAdhocComponents(
	serviceImpl service.AdhocServiceInterface,
	permissionChecker *auth.PermissionChecker,
) *AdhocComponents {
	return &AdhocComponents{
		ServiceImpl:       serviceImpl,
		PermissionChecker: permissionChecker,
	}
}
