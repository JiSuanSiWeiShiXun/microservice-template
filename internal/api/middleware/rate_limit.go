package middleware

import (
	"context"
	"sync"
	"time"

	"github.com/cloudwego/hertz/pkg/app"
	"github.com/cloudwego/hertz/pkg/common/utils"
)

type RateLimiter struct {
	requests map[string][]time.Time
	mu       sync.Mutex
	limit    int
	window   time.Duration
}

func NewRateLimiter(limit int, window time.Duration) *RateLimiter {
	return &RateLimiter{
		requests: make(map[string][]time.Time),
		limit:    limit,
		window:   window,
	}
}

func (rl *RateLimiter) RateLimitMiddleware() app.HandlerFunc {
	return func(ctx context.Context, c *app.RequestContext) {
		clientIP := c.ClientIP()

		rl.mu.Lock()
		defer rl.mu.Unlock()

		now := time.Now()
		if reqs, exists := rl.requests[clientIP]; exists {
			var validReqs []time.Time
			for _, reqTime := range reqs {
				if now.Sub(reqTime) <= rl.window {
					validReqs = append(validReqs, reqTime)
				}
			}
			rl.requests[clientIP] = validReqs
		}

		if len(rl.requests[clientIP]) >= rl.limit {
			c.JSON(429, utils.H{
				"code": 429,
				"msg":  "too many requests",
			})
			c.Abort()
			return
		}

		rl.requests[clientIP] = append(rl.requests[clientIP], now)
		c.Next(ctx)
	}
}
