package observability

import (
	"fmt"
	"time"

	"youlingserv/pkg/log"
)

func RecordHTTPMetrics(method, path string, statusCode int, duration time.Duration) {
	log.GetLogger().Info(
		fmt.Sprintf("HTTP request: method=%s path=%s status=%d duration=%dms",
			method, path, statusCode, duration.Milliseconds()),
	)
}

func RecordGRPCMetrics(method string, err error, duration time.Duration) {
	status := "success"
	if err != nil {
		status = "error"
	}

	log.GetLogger().Info(
		fmt.Sprintf("gRPC request: method=%s status=%s duration=%dms",
			method, status, duration.Milliseconds()),
	)
}
