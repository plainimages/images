ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
ARG NODE_IMAGE=registry.opencode.de/oc000183114358/plainimages/node:22.23.4-pnpm10.10
ARG GO_IMAGE=registry.opencode.de/oc000183114358/plainimages/go:1.26.10
# Keep node, pnpm & go images in sync with versions inside of package.json & go.mod

FROM ${NODE_IMAGE} AS ui-builder

WORKDIR /home/ui-builder

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
# --ignore-scripts skips `prepare`, which downloads a temporal binary and installs git hooks.
RUN pnpm install --frozen-lockfile --ignore-scripts

COPY . ./

RUN pnpm exec svelte-kit sync && pnpm build:server

FROM ${GO_IMAGE} AS server-builder

RUN apk upgrade --no-cache && \
    apk add --no-cache \
    make \
    git \
    curl

WORKDIR /home/server-builder

COPY server/go.mod server/go.sum ./
RUN go mod download

COPY server/ ./
COPY --from=ui-builder /home/ui-builder/server/ui/assets ./ui/assets

RUN make build-server

FROM ${GO_IMAGE} AS dockerize-builder

ARG DOCKERIZE_VERSION=v0.16.0
RUN GOBIN=/out go install github.com/jwilder/dockerize@${DOCKERIZE_VERSION}

FROM ${BASE_IMAGE} AS ui-server

RUN apk upgrade --no-cache && \
    apk add --no-cache \
    ca-certificates \
    tzdata \
    bash

COPY --from=dockerize-builder /out/dockerize /usr/local/bin/dockerize

SHELL ["/bin/bash", "-c"]

ARG TEMPORAL_CLOUD_UI="false"

WORKDIR /home/ui-server

RUN addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal && \
    mkdir ./config

COPY --chown=temporal:temporal --from=server-builder /home/server-builder/ui-server ./
COPY --chown=temporal:temporal server/config/docker.yaml ./config/docker.yaml
COPY --chown=temporal:temporal server/docker/start-ui-server.sh ./start-ui-server.sh

USER temporal

EXPOSE 8080
ENV TEMPORAL_CLOUD_UI=$TEMPORAL_CLOUD_UI
ENTRYPOINT ["./start-ui-server.sh"]
