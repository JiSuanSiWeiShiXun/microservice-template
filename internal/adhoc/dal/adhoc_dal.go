package dal

import (
	"context"
	"fmt"

	"gorm.io/gorm"

	"impirrot/internal/adhoc/dal/model"
	"impirrot/pkg/log"
)

type AdhocDAL struct {
	db *gorm.DB
}

func NewAdhocDAL(db *gorm.DB) AdhocDALInterface {
	return &AdhocDAL{
		db: db,
	}
}

func (d *AdhocDAL) RecordAccess(ctx context.Context, name, action string) error {
	log.GetLogger().Info(fmt.Sprintf("RecordAccess: name=%s, action=%s", name, action))

	record := &model.AdhocAccessLog{
		Name:   name,
		Action: action,
	}

	if err := d.db.WithContext(ctx).Create(record).Error; err != nil {
		log.GetLogger().Error(fmt.Sprintf("Failed to record access: %v", err))
		return nil
	}

	return nil
}

func (d *AdhocDAL) GetAccessLogs(ctx context.Context, name string) ([]*model.AdhocAccessLog, error) {
	var logs []*model.AdhocAccessLog
	err := d.db.WithContext(ctx).Where("name = ?", name).Find(&logs).Error
	if err != nil {
		return nil, err
	}
	return logs, nil
}
