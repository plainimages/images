ARG BASE_IMAGE=golang:1.27.4-alpine3.24
ARG FINAL_IMAGE=cgr.dev/chainguard/static

FROM alpine/git:latest AS src
ARG UPSTREAM_REPO
ARG UPSTREAM_TAG
ARG UPSTREAM_COMMIT
RUN git clone --depth 1 --branch "${UPSTREAM_TAG}" "${UPSTREAM_REPO}" /src \
 && test "$(git -C /src rev-parse HEAD)" = "${UPSTREAM_COMMIT}"

FROM ${BASE_IMAGE} AS spicedb-builder

WORKDIR /go/src/app
COPY --from=src /src/go.mod /src/go.sum ./
RUN go mod download

COPY --from=src /src/ ./

ARG GO_MOD_OVERRIDES="github.com/jackc/pgx/v5@v5.12.0"
RUN go get ${GO_MOD_OVERRIDES} && go mod tidy

RUN CGO_ENABLED=0 go build -tags memoryprotection -buildvcs=false -v -ldflags=-checklinkname=0 \
    -o spicedb ./cmd/spicedb

FROM ${FINAL_IMAGE} AS final

COPY --from=ghcr.io/grpc-ecosystem/grpc-health-probe:v0.4.61 /ko-app/grpc-health-probe \
    /bin/grpc_health_probe
COPY --from=spicedb-builder /go/src/app/spicedb /usr/local/bin/spicedb

ENV PATH="$PATH:/usr/local/bin"
EXPOSE 50051
ENTRYPOINT ["spicedb"]
