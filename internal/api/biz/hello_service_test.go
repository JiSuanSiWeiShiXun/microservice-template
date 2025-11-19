package biz_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"impirrot/internal/api/biz"
	"impirrot/internal/shared/model"
)

// MockUserDAL 模拟 UserDAL
type MockUserDAL struct {
	mock.Mock
}

func (m *MockUserDAL) GetUserByUsername(ctx context.Context, username string) (*model.User, error) {
	args := m.Called(ctx, username)
	return args.Get(0).(*model.User), args.Error(1)
}

func (m *MockUserDAL) GetUserByID(ctx context.Context, id int64) (*model.User, error) {
	args := m.Called(ctx, id)
	return args.Get(0).(*model.User), args.Error(1)
}

func (m *MockUserDAL) CreateUser(ctx context.Context, user *model.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func TestHelloService_SayHello(t *testing.T) {
	// 创建 mock
	mockDAL := &MockUserDAL{}

	// 创建服务实例
	helloService := biz.NewHelloService(mockDAL)

	// 设置期望
	expectedUser := &model.User{
		Username: "john",
		Email:    "john@example.com",
	}
	mockDAL.On("GetUserByUsername", mock.Anything, "john").Return(expectedUser, nil)

	// 执行测试
	ctx := context.Background()
	result, err := helloService.SayHello(ctx, "john", "user123")

	// 验证结果
	assert.NoError(t, err)
	assert.Contains(t, result, "Hello, john!")
	assert.Contains(t, result, "john@example.com")

	// 验证 mock 被调用
	mockDAL.AssertExpectations(t)
}

func TestHelloService_SayHello_UserNotFound(t *testing.T) {
	// 创建 mock
	mockDAL := &MockUserDAL{}

	// 创建服务实例
	helloService := biz.NewHelloService(mockDAL)

	// 设置期望 - 用户不存在
	mockDAL.On("GetUserByUsername", mock.Anything, "unknown").Return((*model.User)(nil), assert.AnError)

	// 执行测试
	ctx := context.Background()
	result, err := helloService.SayHello(ctx, "unknown", "user123")

	// 验证结果
	assert.NoError(t, err)
	assert.Equal(t, "Hello, unknown! Welcome to Impirrot!", result)

	// 验证 mock 被调用
	mockDAL.AssertExpectations(t)
}
