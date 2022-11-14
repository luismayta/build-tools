package test

import (
	"testing"

	"fmt"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/stretchr/testify/assert"

	"github.com/hadenlabs/build-tools/config"
	"github.com/hadenlabs/build-tools/test"
)

func TestBuildToolsBuildSuccess(t *testing.T) {
	t.Parallel()
	conf := config.Initialize()
	test.BuildDocker(t, conf)
	imageTag := conf.Docker.ImageTagLatest()
	opts := &docker.RunOptions{
		Volumes: []string{
			fmt.Sprintf("%s:%s", conf.App.RootPath, "/data"),
		},
		Command: []string{
			"bash", "-c",
			"source /data/provision/scripts/docker/install.sh",
		},
	}
	outputListApps := docker.Run(t, imageTag, opts)
	assert.NotEmpty(t, outputListApps, outputListApps)
}
