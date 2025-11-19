package http

import (
	"context"
	"time"

	"github.com/cloudwego/hertz/pkg/app"
	"impirrot/pkg/observability"
)

func MetricsMiddleware() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		start := time.Now()
		c.Next(ctx)
		duration := time.Since(start)
		path := string(c.Path())
		method := string(c.Method())
		statusCode := c.Response.StatusCode()

		observability.RecordHTTPMetrics(method, path, statusCode, duration)
	}
}
