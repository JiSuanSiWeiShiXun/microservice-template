package grpc

import (
	"context"
	"time"

	"google.golang.org/grpc"

	"impirrot/pkg/observability"
)

func MetricsInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		start := time.Now()
		resp, err := handler(ctx, req)
		duration := time.Since(start)
		observability.RecordGRPCMetrics(info.FullMethod, err, duration)
		return resp, err
	}
}
