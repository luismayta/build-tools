package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/docker"

	"github.com/hadenlabs/build-tools/config"
)

func BuildDocker(t *testing.T, conf *config.Config) {
	imageTag := conf.Docker.ImageTagLatest()
	otherOptions := []string{}

	buildOptions := &docker.BuildOptions{
		Tags:         []string{imageTag},
		OtherOptions: otherOptions,
		BuildArgs: []string{
			"--platform linux/amd64",
		},
	}

	docker.Build(t, "../../", buildOptions)
}
