//go:build wireinject
// +build wireinject

package main

import (
	"github.com/google/wire"
	"gorm.io/gorm"

	"impirrot/internal/adhoc/biz"
	"impirrot/internal/adhoc/dal"
	"impirrot/internal/adhoc/service"
	"impirrot/internal/shared/auth"
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
