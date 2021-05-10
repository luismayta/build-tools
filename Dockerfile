#
# Dockerfile for build-tools
#

FROM hairyhenderson/gomplate:v3.9.0 as gomplate
FROM golangci/golangci-lint:v1.39.0 as golangci-lint
FROM alpine/terragrunt:0.15.0 as hashicorp
FROM wata727/tflint:0.28.0 as tflint

FROM python:3.8.0-slim as base

ENV PATH $PATH:/go/bin:/usr/local/go/bin:/root/.local/bin

ENV BASE_DEPS \
    bash

ENV BUILD_DEPS \
    fakeroot \
    curl \
    openssl

FROM golang:1.16.4 as go-builder

ENV BUILD_DEPS \
    gcc \
    openssl

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    $BUILD_DEPS \
    && go get -u -v golang.org/x/tools/cmd/goimports \
    && go get -u -v github.com/BurntSushi/toml/cmd/tomlv \
    && go get -u -v github.com/preslavmihaylov/todocheck \
    && go get -u -v golang.org/x/lint/golint \
    && go get -u -v github.com/fzipp/gocyclo/cmd/gocyclo \
    && go get -u -v github.com/terraform-docs/terraform-docs@v0.13.0 \
    && go get -u -v github.com/tfsec/tfsec/cmd/tfsec \
    && go get -u -v github.com/go-critic/go-critic/cmd/gocritic


FROM base as crossref

ENV PERSIST_DEPS \
    git \
    shellcheck

ENV MODULES_PYTHON \
    checkov

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    $BASE_DEPS \
    $BUILD_DEPS \
    $PERSIST_DEPS \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && python -m pip install --user --upgrade --no-cache-dir $MODULES_PYTHON \
    && sed -i "s/root:\/root:\/bin\/ash/root:\/root:\/bin\/bash/g" /etc/passwd \
    && apt-get clean \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# go
COPY --from=go-builder /usr/local/go/bin/go /usr/local/go/bin/
COPY --from=go-builder /go/bin/* /go/bin/
COPY --from=gomplate /gomplate /usr/local/bin/gomplate
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/local/bin/golangci-lint

# terraform
COPY --from=hashicorp /bin/terraform /usr/local/bin/
COPY --from=hashicorp /usr/local/bin/terragrunt /usr/local/bin/
COPY --from=tflint /usr/local/bin/tflint /usr/local/bin/

# Reset the work dir
WORKDIR /data

CMD ["/bin/bash"]
