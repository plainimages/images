
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
ARG GO_IMAGE=registry.opencode.de/oc000183114358/plainimages/go:1.27.3

FROM ${GO_IMAGE} AS builder

ARG TARGETARCH
ENV CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH}

WORKDIR /src

COPY temporal/go.mod temporal/go.sum ./temporal/
COPY temporal/common/testx/go.mod ./temporal/common/testx/
COPY cli/go.mod cli/go.sum ./cli/
COPY cli/cliext/go.mod ./cli/cliext/

RUN go -C temporal mod download && \
    go -C cli mod download

COPY temporal/ ./temporal/
COPY cli/ ./cli/

# Build temporal-tool cmd binaries
RUN for t in cassandra sql elasticsearch; do \
        go -C temporal build -tags disable_grpc_modules -o /out/temporal-${t}-tool \
        ./cmd/tools/${t} || exit 1; \
    done && \
    go -C temporal build -tags disable_grpc_modules -o /out/tdbg ./cmd/tools/tdbg && \
    go -C cli build -trimpath -ldflags "-s -w" -o /out/temporal ./cmd/temporal

FROM ${BASE_IMAGE} AS final

COPY --from=builder /out/ /usr/local/bin/
COPY temporal/schema /etc/temporal/schema

RUN apk add --no-cache \
    ca-certificates \
    tzdata && \
    apk upgrade --no-cache zlib && \
    addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal

USER temporal
CMD ["sh", "-c", "trap exit INT HUP TERM; sleep infinity & wait"]
