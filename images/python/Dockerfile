
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
FROM ${BASE_IMAGE}

ARG UPSTREAM_TAG
RUN apk add --no-cache python-${UPSTREAM_TAG} py${UPSTREAM_TAG}-pip uv
