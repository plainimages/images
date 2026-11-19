ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
ARG GO_IMAGE=ghcr.io/plainimages/go:1.27

FROM alpine/git AS src
ARG UPSTREAM_REPO
ARG UPSTREAM_TAG
ARG UPSTREAM_COMMIT
RUN git clone --depth 1 --branch "${UPSTREAM_TAG}" "${UPSTREAM_REPO}" /src \
 && test "$(git -C /src rev-parse HEAD)" = "${UPSTREAM_COMMIT}"

 FROM alpine/git AS cli-src
 ARG UPSTREAM_CLI_REPO
 ARG UPSTREAM_CLI_TAG
 ARG UPSTREAM_CLI_COMMIT
 RUN git clone --depth 1 --branch "${UPSTREAM_CLI_TAG}" "${UPSTREAM_CLI_REPO}" /src \
  && test "$(git -C /src rev-parse HEAD)" = "${UPSTREAM_CLI_COMMIT}"

FROM ${GO_IMAGE} AS builder

ARG TARGETARCH
ENV CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH}
WORKDIR /src

COPY --from=src /src/ ./temporal/
COPY --from=cli-src /src/ ./cli/

ARG GO_MOD_OVERRIDES="github.com/jackc/pgx/v5@v5.12.0"
RUN go -C temporal get ${GO_MOD_OVERRIDES} && \
    go -C temporal mod tidy && \
    go -C temporal mod download && \
    go -C cli mod download

# Build temporal-tool cmd binaries
RUN for t in cassandra sql elasticsearch; do \
        go -C temporal build -tags disable_grpc_modules -o /out/temporal-${t}-tool \
        ./cmd/tools/${t} || exit 1; \
    done && \
    go -C temporal build -tags disable_grpc_modules -o /out/tdbg ./cmd/tools/tdbg && \
    go -C cli build -trimpath -ldflags "-s -w" -o /out/temporal ./cmd/temporal

FROM ${BASE_IMAGE} AS final

COPY --from=builder /out/ /usr/local/bin/
COPY --from=src /src/schema /etc/temporal/schema

RUN apk add --no-cache \
    ca-certificates \
    tzdata && \
    apk upgrade --no-cache zlib && \
    addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal

USER temporal
CMD ["sh", "-c", "trap exit INT HUP TERM; sleep infinity & wait"]
