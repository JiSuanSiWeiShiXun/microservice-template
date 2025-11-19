package config

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"sync"

	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"
	"go.uber.org/zap"

	"impirrot/pkg/log"
)

type (
	Config struct {
		LogConf LogConfig `mapstructure:"log"`
		DBConf  DBConfig  `mapstructure:"db"`
	}

	LogConfig struct {
		Level string `mapstructure:"level"`
	}

	DBConfig struct {
		Host     string `mapstructure:"host"`
		Port     int    `mapstructure:"port"`
		User     string `mapstructure:"user"`
		Pwd      string `mapstructure:"pwd"`
		DataBase string `mapstructure:"database"`
	}
)

var (
	conf Config
	once sync.Once

	CmdConfigName string = "config.yml"
)

func InitLocalConfig(cwd ...string) error {
	// 用变长参数实现唯一入参默认值
	var path string
	var err error
	if len(cwd) == 0 {
		path, err = os.Getwd()
		if err != nil {
			log.GetLogger().Fatal(err.Error())
		}
	} else {
		path = cwd[0]
	}
	confPath := filepath.Join(path, CmdConfigName)
	log.GetLogger().Info(fmt.Sprintf("Loading config from %s", confPath))

	viper.SetConfigFile(confPath)
	viper.SetConfigType("yaml")
	if err = viper.ReadInConfig(); err != nil {
		log.GetLogger().Fatal(err.Error())
	}

	if err := viper.Unmarshal(&conf); err != nil {
		log.GetLogger().Fatal(err.Error())
	}

	// 监控配置文件变化
	viper.WatchConfig()
	viper.OnConfigChange(func(e fsnotify.Event) {
		log.GetLogger().Info("Config file changed:", zap.Any("file", e.Name))
		if err := viper.Unmarshal(&conf); err != nil {
			log.GetLogger().Fatal("Unable to decode into struct: %v", zap.Any("error", err))
		}
	})
	return nil
}

// GetConfig 获取单例
func GetConfig() *Config {
	once.Do(func() {
		if err := InitLocalConfig(); err != nil {
			log.GetLogger().Fatal(err.Error())
		}
	})
	return &conf // 如果变量一直没有使用被操作系统回收了会发生什么？这个变量值是什么？
}

// Stack 打印调用堆栈
func Stack() {
	buf := make([]byte, 1024)
	n := runtime.Stack(buf, false)
	log.GetLogger().Info("Stack trace", zap.String("stack", string(buf[:n])))
}
