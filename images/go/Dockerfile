ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
FROM ${BASE_IMAGE}

ARG SEMVER_VERSION
RUN apk add --no-cache go-${SEMVER_VERSION}

ENV GOPATH=/go
ENV PATH="/go/bin:${PATH}"
