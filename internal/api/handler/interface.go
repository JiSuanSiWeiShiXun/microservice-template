package handler

import (
	"context"

	"github.com/cloudwego/hertz/pkg/app"
)

// HelloHandlerInterface Hello 请求处理器接口
type HelloHandlerInterface interface {
	Handle(ctx context.Context, c *app.RequestContext)
}

// Ensure HelloHandler implements HelloHandlerInterface
var _ HelloHandlerInterface = (*HelloHandler)(nil)
