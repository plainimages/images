ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
ARG GO_IMAGE=registry.opencode.de/oc000183114358/plainimages/go:1.27.3

FROM ${GO_IMAGE} AS builder

ENV CGO_ENABLED=0
WORKDIR /src/temporal

COPY go.mod go.sum ./
COPY common/testx/go.mod ./common/testx/go.mod
RUN go mod download

COPY . ./
RUN go build -tags disable_grpc_modules -o /out/temporal-server ./cmd/server

FROM ${BASE_IMAGE} AS final

COPY --from=builder /out/temporal-server /usr/local/bin/temporal-server
COPY docker/scripts/sh/entrypoint.sh /etc/temporal/entrypoint.sh

RUN apk add --no-cache \
    ca-certificates \
    tzdata && \
    apk upgrade --no-cache zlib && \
    chmod 755 /usr/local/bin/temporal-server /etc/temporal/entrypoint.sh && \
    addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal

WORKDIR /etc/temporal
USER temporal

CMD [ "/etc/temporal/entrypoint.sh" ]
