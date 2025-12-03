package grpc

import (
	"context"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"

	"youlingserv/internal/shared/auth"
)

func AuthInterceptor(checker *auth.PermissionChecker) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			return nil, status.Error(codes.Unauthenticated, "missing metadata")
		}

		userIDs := md.Get("user-id")
		if len(userIDs) == 0 {
			return nil, status.Error(codes.Unauthenticated, "missing user ID")
		}
		userID := userIDs[0]

		err := checker.CheckAccess(ctx, userID, "grpc", "call")
		if err != nil {
			return nil, status.Error(codes.PermissionDenied, err.Error())
		}

		ctx = context.WithValue(ctx, "userID", userID)
		return handler(ctx, req)
	}
}
