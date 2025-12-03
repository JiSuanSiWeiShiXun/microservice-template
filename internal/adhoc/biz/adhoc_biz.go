package biz

import (
	"context"
	"fmt"

	"youlingserv/internal/adhoc/dal"
	"youlingserv/pkg/log"
)

type AdhocBiz struct {
	adhocDAL dal.AdhocDALInterface
}

func NewAdhocBiz(adhocDAL dal.AdhocDALInterface) AdhocBizInterface {
	return &AdhocBiz{
		adhocDAL: adhocDAL,
	}
}

func (b *AdhocBiz) ProcessHello(ctx context.Context, name string) (string, error) {
	log.GetLogger().Info(fmt.Sprintf("ProcessHello: name=%s", name))

	err := b.adhocDAL.RecordAccess(ctx, name, "hello")
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("Hello from Adhoc service, %s!", name), nil
}

func (b *AdhocBiz) ProcessGoodbye(ctx context.Context, name string) (string, error) {
	log.GetLogger().Info(fmt.Sprintf("ProcessGoodbye: name=%s", name))

	err := b.adhocDAL.RecordAccess(ctx, name, "goodbye")
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("Goodbye, %s! See you next time!", name), nil
}
