package log

import (
	"sync"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

type Logger struct {
	*zap.Logger
}

var logger *Logger
var once sync.Once

func GetLogger() *Logger {
	once.Do(func() {
		cfg := zap.NewProductionConfig()
		cfg.Level = zap.NewAtomicLevelAt(zap.DebugLevel)

		cfg.EncoderConfig.TimeKey = "time"
		cfg.EncoderConfig.EncodeTime = func(t time.Time, enc zapcore.PrimitiveArrayEncoder) {
			// 转换为 UTC+8 时区
			loc, _ := time.LoadLocation("Asia/Shanghai")
			enc.AppendString(t.In(loc).Format("2006-01-02 15:04:05.000"))
		}
		l, err := cfg.Build()
		if err != nil {
			panic(err)
		}
		logger = &Logger{Logger: l}
	})
	return logger
}
