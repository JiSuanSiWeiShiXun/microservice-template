package service

import (
	"context"
	"fmt"

	adhocv1 "youlingserv/gen/go/adhoc/v1"
	"youlingserv/internal/adhoc/biz"
	"youlingserv/pkg/log"
)

type AdhocServiceImpl struct {
	adhocv1.UnimplementedAdhocServiceServer
	adhocBiz biz.AdhocBizInterface
}

func NewAdhocServiceImpl(adhocBiz biz.AdhocBizInterface) AdhocServiceInterface {
	return &AdhocServiceImpl{
		adhocBiz: adhocBiz,
	}
}

func (s *AdhocServiceImpl) Hello(ctx context.Context, req *adhocv1.HelloRequest) (*adhocv1.HelloResponse, error) {
	log.GetLogger().Info(fmt.Sprintf("Adhoc Hello called: name=%s", req.Name))
	return &adhocv1.HelloResponse{
		Response: fmt.Sprintf("hello, %s!", req.Name),
	}, nil
}

func (s *AdhocServiceImpl) Goodbye(ctx context.Context, req *adhocv1.GoodbyeRequest) (*adhocv1.GoodbyeResponse, error) {
	log.GetLogger().Info(fmt.Sprintf("Adhoc Goodbye called: name=%s", req.Name))

	return &adhocv1.GoodbyeResponse{
		Farewell: fmt.Sprintf("goodbye, %s~", req.Name),
	}, nil
}
