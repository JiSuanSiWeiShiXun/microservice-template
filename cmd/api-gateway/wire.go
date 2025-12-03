//go:build wireinject
// +build wireinject

package main

import (
	"github.com/google/wire"
	"gorm.io/gorm"

	"impirrot/internal/api/biz"
	"impirrot/internal/api/dal"
	"impirrot/internal/api/handler"
	"impirrot/internal/shared/auth"
)

// InitializeAPIService 初始化 API 服务的所有依赖
func InitializeAPIService(db *gorm.DB) (*APIComponents, error) {
	wire.Build(
		// DAL 层
		dal.NewUserDAL,

		// Biz 层
		biz.NewHelloService,

		// Handler 层
		handler.NewHelloHandler,

		// Auth
		auth.NewAuthClient,
		auth.NewPermissionChecker,

		// 组件聚合
		NewAPIComponents,
	)
	return nil, nil
}
