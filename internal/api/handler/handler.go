package handler

import (
	"context"

	"github.com/cloudwego/hertz/pkg/app"
	"github.com/cloudwego/hertz/pkg/common/utils"

	"impirrot/internal/api/biz"
	"impirrot/pkg/dto"
)

type HelloHandler struct {
	helloService biz.HelloServiceInterface
}

func NewHelloHandler(helloService biz.HelloServiceInterface) HelloHandlerInterface {
	return &HelloHandler{
		helloService: helloService,
	}
}

type HelloRequest struct {
	Name string `json:"name" binding:"required"`
}

func (h *HelloHandler) Handle(ctx context.Context, c *app.RequestContext) {
	var req HelloRequest
	if err := c.BindJSON(&req); err != nil {
		c.JSON(400, dto.ErrorResponse(400, "invalid request: "+err.Error()))
		return
	}

	userID, _ := c.Get("userID")

	message, err := h.helloService.SayHello(ctx, req.Name, userID.(string))
	if err != nil {
		c.JSON(500, dto.ErrorResponse(500, err.Error()))
		return
	}

	c.JSON(200, dto.SuccessResponse(utils.H{
		"message": message,
	}))
}
