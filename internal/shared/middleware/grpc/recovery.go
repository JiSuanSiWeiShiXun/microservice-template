package grpc

import (
	"context"
	"fmt"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"impirrot/pkg/log"
)

func RecoveryInterceptor() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (resp interface{}, err error) {
		defer func() {
			if r := recover(); r != nil {
				log.GetLogger().Error(fmt.Sprintf("panic recovered: %v", r))
				err = status.Errorf(codes.Internal, "internal server error: %v", r)
			}
		}()

		return handler(ctx, req)
	}
}
