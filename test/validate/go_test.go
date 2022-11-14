package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/stretchr/testify/assert"

	"github.com/hadenlabs/build-tools/config"
	"github.com/hadenlabs/build-tools/test"
)

func TestBuildToolsValidateGoSuccess(t *testing.T) {
	t.Parallel()
	conf := config.Initialize()
	test.BuildDocker(t, conf)
	imageTag := conf.Docker.ImageTagLatest()
	expectApps := []string{
		"gocritic",
		"gocyclo",
		"goimports",
		"golangci-lint",
		"golint",
	}

	opts := &docker.RunOptions{
		Command: []string{
			"bash", "-c",
			"compgen -c", "|",
			"sort -u",
		},
	}
	outputListApps := docker.Run(t, imageTag, opts)
	assert.NotEmpty(t, outputListApps, outputListApps)
	assert.Subset(t, strings.Split(outputListApps, "\n"), expectApps)
}
