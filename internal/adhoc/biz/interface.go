package biz

import "context"

// AdhocBizInterface Adhoc 业务逻辑接口
type AdhocBizInterface interface {
	ProcessHello(ctx context.Context, name string) (string, error)
	ProcessGoodbye(ctx context.Context, name string) (string, error)
}

// Ensure AdhocBiz implements AdhocBizInterface
var _ AdhocBizInterface = (*AdhocBiz)(nil)
