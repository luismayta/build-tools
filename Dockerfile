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

FROM go-builder AS tfsec

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    github.com/aquasecurity/tfsec/cmd/tfsec@latest \
    && upx -9 ${GOPATH}/bin/tfsec

FROM go-builder AS todocheck

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    github.com/preslavmihaylov/todocheck \
    && upx -9 ${GOPATH}/bin/todocheck

FROM go-builder AS golint

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    golang.org/x/lint/golint \
    && upx -9 ${GOPATH}/bin/golint

FROM go-builder AS tomlv

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    github.com/BurntSushi/toml/cmd/tomlv \
    && upx -9 ${GOPATH}/bin/tomlv

FROM go-builder AS terraform-docs

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    github.com/terraform-docs/terraform-docs@v0.13.0 \
    && upx -9 ${GOPATH}/bin/terraform-docs

FROM go-builder AS goimports

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    golang.org/x/tools/cmd/goimports \
    && upx -9 ${GOPATH}/bin/goimports

FROM go-builder AS gocyclo

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    github.com/fzipp/gocyclo/cmd/gocyclo \
    && upx -9 ${GOPATH}/bin/gocyclo

FROM go-builder AS gocritic

RUN GO111MODULE=on go get -u  \
    --ldflags "-s -w" --trimpath \
    github.com/go-critic/go-critic/cmd/gocritic \
    && upx -9 ${GOPATH}/bin/gocritic

FROM base as crossref

ENV PERSIST_DEPS \
    git \
    shellcheck

ENV MODULES_PYTHON \
    checkov

ENV GOPATH /go

ENV GOROOT /usr/local/go

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

# Go
COPY --from=gomplate /gomplate /usr/local/bin/gomplate
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/local/bin/golangci-lint
COPY --from=gocritic $GOPATH/bin/gocritic $GOPATH/bin/gocritic
COPY --from=gocyclo $GOPATH/bin/gocyclo $GOPATH/bin/gocyclo
COPY --from=goimports $GOPATH/bin/goimports $GOPATH/bin/goimports
COPY --from=terraform-docs $GOPATH/bin/terraform-docs $GOPATH/bin/terraform-docs
COPY --from=tomlv $GOPATH/bin/tomlv $GOPATH/bin/tomlv
COPY --from=golint $GOPATH/bin/golint $GOPATH/bin/golint
COPY --from=todocheck $GOPATH/bin/todocheck $GOPATH/bin/todocheck

# terraform
COPY --from=tfsec $GOPATH/bin/tfsec $GOPATH/bin/tfsec
COPY --from=hashicorp /bin/terraform /usr/local/bin/
COPY --from=hashicorp /usr/local/bin/terragrunt /usr/local/bin/
COPY --from=tflint /usr/local/bin/tflint /usr/local/bin/

# Reset the work dir
WORKDIR /data

CMD ["/bin/bash"]
