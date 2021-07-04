package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/docker"
	"github.com/stretchr/testify/assert"

	"github.com/hadenlabs/build-tools/config"
)

func TestBuildToolsValidateTerraformSuccess(t *testing.T) {
	conf := config.Initialize()
	imageTag := conf.Docker.ImageTagLatest()
	otherOptions := []string{}
	expectApps := []string{
		"terraform",
		"terraform-docs",
		"tflint",
		"tfsec",
		"checkov",
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
