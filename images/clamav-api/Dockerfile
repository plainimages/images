ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
ARG GO_IMAGE=registry.opencode.de/oc000183114358/plainimages/go:1.27

FROM alpine/git AS src
ARG UPSTREAM_REPO
ARG UPSTREAM_TAG
ARG UPSTREAM_COMMIT
RUN git clone --depth 1 --branch "${UPSTREAM_TAG}" "${UPSTREAM_REPO}" /src \
 && test "$(git -C /src rev-parse HEAD)" = "${UPSTREAM_COMMIT}"

FROM ${GO_IMAGE} AS builder
ARG TARGETARCH=amd64

RUN apk add --no-cache protoc && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.10 && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1

WORKDIR /src
COPY --from=src /src/ ./

RUN protoc --go_out=. --go_opt=paths=source_relative \
           --go-grpc_out=. --go-grpc_opt=paths=source_relative \
           proto/clamav.proto

# CVE-2026-78663
ARG GO_MOD_OVERRIDES="golang.org/x/net@v0.60.0"
RUN go get ${GO_MOD_OVERRIDES} && go mod tidy
RUN cd src && \
    CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} \
    go build -o /out/clamav-api .

FROM ${BASE_IMAGE}

ARG TARGETARCH=amd64
ENV APP_NAME=clamav-api
ENV APP_ENV=production
ENV CLAMAV_PORT=6000
ENV CLAMAV_GRPC_PORT=9000
ENV CLAMAV_SOCKET=/var/run/clamav/clamd.ctl

COPY --from=builder /out/clamav-api /app/clamav-api

# Install required packages
RUN apk add --no-cache \
    supervisor \
    clamav \
    clamav-libunrar \
    ca-certificates

# Create clamav user and group
RUN addgroup -S clamav && \
    adduser -S -G clamav clamav && \
    adduser clamav clamav

# Configure clamavd
RUN mkdir -p /var/run/clamav && \
    mkdir -p /var/log/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chown clamav:clamav -R /var/lib/clamav && \
    chown clamav:clamav /var/log/clamav && \
    chmod 750 /var/run/clamav

# Copy configurations
COPY --from=src /src/docker/clamavd/config/clamav /etc/clamav/
COPY --from=src /src/docker/common/config/supervisord.conf /etc/supervisord.conf
COPY --from=src /src/docker/clamavd/config/supervisord /etc/supervisor/conf.d/

# Copy init scripts and set permissions
COPY --from=src /src/docker/common/init /init/
COPY --from=src /src/docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh /init/* && \
    chown -R clamav:clamav /init /docker-entrypoint.sh && \
    chmod 755 /usr/sbin/clamd

# Copy pre-built binary from bin directory
WORKDIR /app
RUN chown clamav:clamav /app/clamav-api && \
    chmod +x /app/clamav-api

# Declare volumes for persistence
VOLUME ["/var/lib/clamav", "/var/run/clamav"]

WORKDIR /
EXPOSE 6000 9000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD sh -c "wget --spider -q http://localhost:${CLAMAV_PORT:-6000}/api/health-check || exit 1"

ENTRYPOINT ["./docker-entrypoint.sh"]
