package dal

import (
	"context"

	"youlingserv/internal/adhoc/dal/model"
)

// AdhocDALInterface Adhoc 数据访问层接口
type AdhocDALInterface interface {
	RecordAccess(ctx context.Context, name, action string) error
	GetAccessLogs(ctx context.Context, name string) ([]*model.AdhocAccessLog, error)
}

// Ensure AdhocDAL implements AdhocDALInterface
var _ AdhocDALInterface = (*AdhocDAL)(nil)
