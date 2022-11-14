package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/stretchr/testify/assert"

	"github.com/hadenlabs/build-tools/config"
	"github.com/hadenlabs/build-tools/test"
)

func TestToolsBuilderSuccess(t *testing.T) {
	t.Parallel()
	conf := config.Initialize()
	test.BuildDocker(t, conf)
	imageTag := conf.Docker.ImageTagLatest()
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
	t.Parallel()
	conf := config.Initialize()
	test.BuildDocker(t, conf)
	imageTag := conf.Docker.ImageTagLatest()
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
