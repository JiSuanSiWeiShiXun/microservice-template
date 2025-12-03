package biz

import (
	"context"
	"fmt"

	"youlingserv/internal/api/dal"
	"youlingserv/pkg/log"
)

type HelloService struct {
	userDAL dal.UserDALInterface
}

func NewHelloService(userDAL dal.UserDALInterface) HelloServiceInterface {
	return &HelloService{
		userDAL: userDAL,
	}
}

func (s *HelloService) SayHello(ctx context.Context, name, userID string) (string, error) {
	log.GetLogger().Info(fmt.Sprintf("SayHello called: name=%s, userID=%s", name, userID))

	user, err := s.userDAL.GetUserByUsername(ctx, name)
	if err != nil {
		return fmt.Sprintf("Hello, %s! Welcome to youlingserv!", name), nil
	}

	return fmt.Sprintf("Hello, %s! Your email is %s", user.Username, user.Email), nil
}
