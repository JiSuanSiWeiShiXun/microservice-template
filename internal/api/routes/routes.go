package routes

import (
	"github.com/cloudwego/hertz/pkg/app/server"

	"youlingserv/internal/api/handler"
)

// RegisterAPIRoutes 注册 API 路由
func RegisterAPIRoutes(h *server.Hertz, helloHandler handler.HelloHandlerInterface) {
	v1 := h.Group("/api/v1")
	{
		v1.POST("/hello", helloHandler.Handle)
	}
}
