package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/hadenlabs/build-tools/config"
	"github.com/stretchr/testify/assert"
)

func TestBuildToolsValidateGoSuccess(t *testing.T) {
	conf := config.Initialize()
	imageTag := conf.Docker.ImageTagLatest()
	otherOptions := []string{}
	expectApps := []string{
		"gocritic",
		"gocyclo",
		"goimports",
		"golangci-lint",
		"golint",
	}

	buildOptions := &docker.BuildOptions{
		Tags:         []string{imageTag},
		OtherOptions: otherOptions,
	}

	docker.Build(t, "../../", buildOptions)
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
