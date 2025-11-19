package auth

import (
	"context"
	"errors"
)

type AuthClient interface {
	CheckPermission(ctx context.Context, userID, resource, action string) (bool, error)
}

type mockAuthClient struct{}

func NewAuthClient() AuthClient {
	return &mockAuthClient{}
}

func (m *mockAuthClient) CheckPermission(ctx context.Context, userID, resource, action string) (bool, error) {
	if userID == "" {
		return false, errors.New("user ID is required")
	}
	return true, nil
}
