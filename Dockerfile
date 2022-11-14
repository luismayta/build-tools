#
# Dockerfile for build-tools
#

FROM hairyhenderson/gomplate:v3.9.0 as gomplate
FROM golangci/golangci-lint:v1.46.2 as golangci-lint
FROM alpine/terragrunt:1.3.4 as hashicorp

FROM python:3.10.6-slim as base

ENV PATH $PATH:/go/bin:/usr/local/go/bin:/root/.local/bin

ENV BASE_DEPS \
    bash

ENV BUILD_DEPS \
    fakeroot \
    curl \
    openssl

FROM golang:1.18.4 as go-builder

ENV GOPATH /go
ENV GOROOT /usr/local/go

ENV GO111MODULE on
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8
ENV GOFLAGS "-ldflags=-w -ldflags=-s"

ENV BUILD_DEPS \
    gcc \
    openssl

ENV PERSIST_DEPS \
    upx

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    ${BUILD_DEPS} \
    ${PERSIST_DEPS} \
    && apt-get clean \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


FROM go-builder AS go-install

RUN go install github.com/cweill/gotests/gotests@latest \
    && go install github.com/aquasecurity/tfsec/cmd/tfsec@latest \
    && go install github.com/preslavmihaylov/todocheck@latest \
    && go install golang.org/x/lint/golint@latest \
    && go install github.com/BurntSushi/toml/cmd/tomlv@latest \
    && go install github.com/terraform-docs/terraform-docs@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install github.com/fzipp/gocyclo/cmd/gocyclo@latest \
    && go install github.com/go-critic/go-critic/cmd/gocritic@latest \
    && go install github.com/zricethezav/gitleaks@latest \
    && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest \
    && go install github.com/terraform-linters/tflint@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install github.com/pwaller/goimports-update-ignore@latest \
    && apt-get clean \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


FROM base as crossref

ENV PERSIST_DEPS \
    git \
    shellcheck

ENV MODULES_PYTHON \
    checkov \
    pipenv

ENV GOPATH /go

ENV GOROOT /usr/local/go

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    ${BASE_DEPS} \
    ${BUILD_DEPS} \
    ${PERSIST_DEPS} \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && python -m pip install --user --upgrade --no-cache-dir ${MODULES_PYTHON} \
    && sed -i "s/root:\/root:\/bin\/ash/root:\/root:\/bin\/bash/g" /etc/passwd \
    && apt-get clean \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Go
COPY --from=go-install ${GOROOT}/bin ${GOROOT}/bin
COPY --from=go-install ${GOROOT}/src ${GOROOT}/src
COPY --from=go-install ${GOROOT}/lib ${GOROOT}/lib
COPY --from=go-install ${GOROOT}/pkg ${GOROOT}/pkg
COPY --from=go-install ${GOROOT}/misc ${GOROOT}/misc
COPY --from=go-install ${GOPATH}/bin ${GOPATH}/bin

COPY --from=gomplate /gomplate /usr/local/bin/gomplate
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/local/bin/golangci-lint

# terraform
COPY --from=hashicorp /bin/terraform /usr/local/bin/
COPY --from=hashicorp /usr/local/bin/terragrunt /usr/local/bin/

# Reset the work dir
WORKDIR /data

CMD ["/bin/bash"]
