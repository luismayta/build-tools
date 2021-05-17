package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/hadenlabs/build-tools/config"
	"github.com/stretchr/testify/assert"
)

func TestToolsBuilderSuccess(t *testing.T) {
	conf := config.Initialize()
	imageTag := conf.Docker.ImageTagLatest()
	otherOptions := []string{}
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
}

func TestGetDockerBuilderSuccess(t *testing.T) {
	conf := config.Initialize()
	imageTag := conf.Docker.ImageTagLatest()
	otherOptions := []string{}
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
}
