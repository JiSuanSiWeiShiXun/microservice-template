package http

import (
	"context"

	"youlingserv/internal/shared/auth"

	"github.com/cloudwego/hertz/pkg/app"
	"github.com/cloudwego/hertz/pkg/common/utils"
)

func AuthMiddleware(checker *auth.PermissionChecker) app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		userID := string(c.GetHeader("X-User-ID"))
		if userID == "" {
			c.JSON(401, utils.H{
				"code": 401,
				"msg":  "unauthorized: missing user ID",
			})
			c.Abort()
			return
		}

		err := checker.CheckAccess(ctx, userID, "api", "access")
		if err != nil {
			c.JSON(403, utils.H{
				"code": 403,
				"msg":  "forbidden: " + err.Error(),
			})
			c.Abort()
			return
		}

		c.Set("userID", userID)
		c.Next(ctx)
	}
}
