package service

import (
	"context"
	"fmt"

	adhocv1 "youlingserv/gen/go/adhoc/v1"
	commonpb "youlingserv/gen/go/common"
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

	message, err := s.adhocBiz.ProcessHello(ctx, req.Name)
	if err != nil {
		return &adhocv1.HelloResponse{
			Response: &commonpb.CommonResponse{
				Code: 1,
				Msg:  err.Error(),
			},
		}, nil
	}

	return &adhocv1.HelloResponse{
		Response: &commonpb.CommonResponse{
			Code: 0,
			Msg:  message,
		},
	}, nil
}

func (s *AdhocServiceImpl) Goodbye(ctx context.Context, req *adhocv1.GoodbyeRequest) (*adhocv1.GoodbyeResponse, error) {
	log.GetLogger().Info(fmt.Sprintf("Adhoc Goodbye called: name=%s", req.Name))

	farewell, err := s.adhocBiz.ProcessGoodbye(ctx, req.Name)
	if err != nil {
		return &adhocv1.GoodbyeResponse{
			Response: &commonpb.CommonResponse{
				Code: 1,
				Msg:  err.Error(),
			},
		}, nil
	}

	return &adhocv1.GoodbyeResponse{
		Response: &commonpb.CommonResponse{
			Code: 0,
			Msg:  "success",
		},
		Farewell: farewell,
	}, nil
}
