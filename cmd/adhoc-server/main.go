package main

import (
	"fmt"
	"net"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"gorm.io/gorm"

	"youlingserv/internal/adhoc/routes"
	grpcMiddleware "youlingserv/internal/shared/middleware/grpc"
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
	log.GetLogger().Info("Adhoc gRPC Server starting...")

	// 初始化数据库连接
	// db, err := initDatabase()
	// if err != nil {
	// 	panic(fmt.Sprintf("Failed to connect to MySQL: %v", err))
	// }

	// 使用 Wire 初始化所有依赖
	components, err := InitializeAdhocService(nil)
	if err != nil {
		panic(fmt.Sprintf("Failed to initialize Adhoc service: %v", err))
	}

	// 创建并配置 gRPC 服务器
	grpcServer := setupGRPCServer(components)

	// 启用 gRPC 反射（用于 grpcurl 等工具）
	reflection.Register(grpcServer)

	// 注册服务
	routes.RegisterAdhocRoutes(grpcServer, components.ServiceImpl)

	// 启动服务器
	if err := startServer(grpcServer); err != nil {
		panic(fmt.Sprintf("Failed to serve: %v", err))
	}
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

// setupGRPCServer 配置 gRPC 服务器
func setupGRPCServer(components *AdhocComponents) *grpc.Server {
	return grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			grpcMiddleware.RecoveryInterceptor(),
			grpcMiddleware.MetricsInterceptor(),
			grpcMiddleware.AuthInterceptor(components.PermissionChecker),
		),
	)
}

// startServer 启动 gRPC 服务器
func startServer(grpcServer *grpc.Server) error {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		return fmt.Errorf("failed to listen: %w", err)
	}

	log.GetLogger().Info("Adhoc gRPC Server started on :50051")
	return grpcServer.Serve(lis)
}
