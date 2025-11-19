package model

import "time"

// User ORM 模型示例
type User struct {
	ID        int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	Username  string    `gorm:"type:varchar(50);not null;uniqueIndex" json:"username"`
	Email     string    `gorm:"type:varchar(100);not null;uniqueIndex" json:"email"`
	Status    int       `gorm:"type:tinyint;default:1" json:"status"` // 1=active, 0=inactive
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// TableName 指定表名
func (User) TableName() string {
	return "users"
}
