//go:build wireinject
// +build wireinject

package main

import (
	"github.com/google/wire"
	"gorm.io/gorm"

	"youlingserv/internal/adhoc/biz"
	"youlingserv/internal/adhoc/dal"
	"youlingserv/internal/adhoc/service"
	"youlingserv/internal/shared/auth"
)

// InitializeAdhocService 初始化 Adhoc 服务的所有依赖
func InitializeAdhocService(db *gorm.DB) (*AdhocComponents, error) {
	wire.Build(
		// DAL 层
		dal.NewAdhocDAL,

		// Biz 层
		biz.NewAdhocBiz,

		// Service 层
		service.NewAdhocServiceImpl,

		// Auth
		auth.NewAuthClient,
		auth.NewPermissionChecker,

		// 组件聚合
		NewAdhocComponents,
	)
	return nil, nil
}
