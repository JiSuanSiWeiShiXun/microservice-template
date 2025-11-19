package service

import (
	"context"

	adhocv1 "impirrot/gen/go/adhoc/v1"
)

// AdhocServiceInterface Adhoc 服务接口
type AdhocServiceInterface interface {
	Hello(ctx context.Context, req *adhocv1.HelloRequest) (*adhocv1.HelloResponse, error)
	Goodbye(ctx context.Context, req *adhocv1.GoodbyeRequest) (*adhocv1.GoodbyeResponse, error)
}

// Ensure AdhocServiceImpl implements AdhocServiceInterface
var _ AdhocServiceInterface = (*AdhocServiceImpl)(nil)
