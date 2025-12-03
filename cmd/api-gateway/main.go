package main

import (
	"fmt"
	"time"

	"github.com/cloudwego/hertz/pkg/app/server"
	"gorm.io/gorm"

	"youlingserv/internal/api/middleware"
	"youlingserv/internal/api/routes"
	httpMiddleware "youlingserv/internal/shared/middleware/http"
	"youlingserv/pkg/config"
	"youlingserv/pkg/database"
	"youlingserv/pkg/log"
)

func main() {
	// 初始化配置
	if err := config.InitLocalConfig(); err != nil {
		panic(fmt.Sprintf("Failed to init config: %v", err))
	}

	// 初始化日志
	log.GetLogger().Info("API Gateway starting...")

	// 初始化数据库连接
	// db, err := initDatabase()
	// if err != nil {
	// 	panic(fmt.Sprintf("Failed to connect to MySQL: %v", err))
	// }

	// 使用 Wire 初始化所有依赖
	components, err := InitializeAPIService(nil)
	if err != nil {
		panic(fmt.Sprintf("Failed to initialize API service: %v", err))
	}

	// 初始化限流器
	rateLimiter := middleware.NewRateLimiter(100, time.Minute)

	// 创建并配置 HTTP 服务器
	h := setupServer(components, rateLimiter)

	// 启动服务器
	log.GetLogger().Info("API Gateway started on :8080")
	h.Spin()
}

// initDatabase 初始化数据库连接
func initDatabase() (*gorm.DB, error) {
	return database.NewMySQLConnection(&database.MySQLConfig{
		Host:     "localhost",
		Port:     3306,
		User:     "root",
		Password: "password",
		Database: "youlingserv",
	})
}

// setupServer 配置 HTTP 服务器
func setupServer(components *APIComponents, rateLimiter *middleware.RateLimiter) *server.Hertz {
	h := server.Default(
		server.WithHostPorts("0.0.0.0:6789"),
		server.WithMaxRequestBodySize(4*1024*1024), // 4MB
	)

	// 注册全局中间件
	h.Use(httpMiddleware.CORSMiddleware())
	h.Use(httpMiddleware.MetricsMiddleware())
	h.Use(rateLimiter.RateLimitMiddleware())
	h.Use(httpMiddleware.AuthMiddleware(components.PermissionChecker))

	// 注册路由
	routes.RegisterAPIRoutes(h, components.HelloHandler)

	return h
}
