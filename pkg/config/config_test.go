package config

import (
	"testing"
)

func TestConfig(t *testing.T) {
	if err := InitLocalConfig("../../"); err != nil {
		panic(err)
	}
	t.Logf("config: %v", GetConfig())
}
