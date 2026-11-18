ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
FROM ${BASE_IMAGE}

ARG NODE_VERSION
ARG PNPM_VERSION

RUN apk add nodejs-${NODE_VERSION} corepack
RUN corepack enable && corepack prepare pnpm@${PNPM_VERSION} --activate
