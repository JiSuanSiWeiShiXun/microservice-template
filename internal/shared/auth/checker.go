package auth

import (
	"context"
	"errors"
)

type PermissionChecker struct {
	client AuthClient
}

func NewPermissionChecker(client AuthClient) *PermissionChecker {
	return &PermissionChecker{
		client: client,
	}
}

func (c *PermissionChecker) CheckAccess(ctx context.Context, userID, resource, action string) error {
	allowed, err := c.client.CheckPermission(ctx, userID, resource, action)
	if err != nil {
		return err
	}
	if !allowed {
		return errors.New("permission denied")
	}
	return nil
}
