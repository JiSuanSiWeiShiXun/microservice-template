package dal

import (
	"context"

	"gorm.io/gorm"

	"impirrot/internal/shared/model"
)

type UserDAL struct {
	db *gorm.DB
}

func NewUserDAL(db *gorm.DB) UserDALInterface {
	return &UserDAL{
		db: db,
	}
}

func (d *UserDAL) GetUserByUsername(ctx context.Context, username string) (*model.User, error) {
	var user model.User
	err := d.db.WithContext(ctx).Where("username = ?", username).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (d *UserDAL) GetUserByID(ctx context.Context, id int64) (*model.User, error) {
	var user model.User
	err := d.db.WithContext(ctx).First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (d *UserDAL) CreateUser(ctx context.Context, user *model.User) error {
	return d.db.WithContext(ctx).Create(user).Error
}
