ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
FROM ${BASE_IMAGE}

ARG GO_VERSION
RUN apk add --no-cache go-${GO_VERSION}

ENV GOPATH=/go
ENV PATH="/go/bin:${PATH}"
