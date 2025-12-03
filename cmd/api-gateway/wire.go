//go:build wireinject
// +build wireinject

package main

import (
	"github.com/google/wire"
	"gorm.io/gorm"

	"youlingserv/internal/api/biz"
	"youlingserv/internal/api/dal"
	"youlingserv/internal/api/handler"
	"youlingserv/internal/shared/auth"
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
