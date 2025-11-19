package model

import "time"

type AdhocUser struct {
	ID   int64  `gorm:"primaryKey;autoIncrement" json:"id"`
	Name string `gorm:"type:varchar(50);not null" json:"name"`
}

func (AdhocUser) TableName() string {
	return "adhoc_users"
}

type AdhocAccessLog struct {
	ID        int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	Name      string    `gorm:"type:varchar(50);not null" json:"name"`
	Action    string    `gorm:"type:varchar(20);not null" json:"action"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}

func (AdhocAccessLog) TableName() string {
	return "adhoc_access_logs"
}
