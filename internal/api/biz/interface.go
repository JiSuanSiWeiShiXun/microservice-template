package biz

import "context"

// HelloServiceInterface Hello 业务逻辑接口
type HelloServiceInterface interface {
	SayHello(ctx context.Context, name, userID string) (string, error)
}

// Ensure HelloService implements HelloServiceInterface
var _ HelloServiceInterface = (*HelloService)(nil)
