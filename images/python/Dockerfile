ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
FROM ${BASE_IMAGE}

ARG SEMVER_VERSION
RUN apk add --no-cache python-${SEMVER_VERSION} py${SEMVER_VERSION}-pip uv
