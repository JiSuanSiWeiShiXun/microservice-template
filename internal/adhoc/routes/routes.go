package routes

import (
	"google.golang.org/grpc"

	adhocv1 "youlingserv/gen/go/adhoc/v1"
	"youlingserv/internal/adhoc/service"
)

// RegisterAdhocRoutes 注册 Adhoc gRPC 服务
func RegisterAdhocRoutes(grpcServer *grpc.Server, adhocService service.AdhocServiceInterface) {
	adhocv1.RegisterAdhocServiceServer(grpcServer, adhocService.(*service.AdhocServiceImpl))
}
