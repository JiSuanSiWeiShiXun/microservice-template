package dal

import (
	"context"

	"impirrot/internal/shared/model"
)

// UserDALInterface 用户数据访问层接口
type UserDALInterface interface {
	GetUserByUsername(ctx context.Context, username string) (*model.User, error)
	GetUserByID(ctx context.Context, id int64) (*model.User, error)
	CreateUser(ctx context.Context, user *model.User) error
}

// Ensure UserDAL implements UserDALInterface
var _ UserDALInterface = (*UserDAL)(nil)
