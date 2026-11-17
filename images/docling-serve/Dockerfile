ARG BASE_IMAGE=registry.opencode.de/oc000183114358/plainimages/python:3.12-nightly
ARG BUILDER_IMAGE=registry.opencode.de/oc000183114358/plainimages/python@sha256:055216d3f07a55bbbb1287c6bd396e23f133f66671c852df2a730ddc903a12b0
ARG NODE_IMAGE=registry.opencode.de/oc000183114358/plainimages/node:24-npm-nightly

ARG UV_SYNC_EXTRA_ARGS=""
ARG MIMALLOC_VERSION=v3.2.8
ARG TESSDATA_VERSION=4.1.0

FROM alpine/git:2.49.1 AS src
ARG UPSTREAM_REPO
ARG UPSTREAM_TAG
ARG UPSTREAM_COMMIT
RUN git clone --depth 1 --branch "${UPSTREAM_TAG}" "${UPSTREAM_REPO}" /src \
 && test "$(git -C /src rev-parse HEAD)" = "${UPSTREAM_COMMIT}"

###################################################################################################
# Build mimalloc                                                                                  #
###################################################################################################

FROM ${BASE_IMAGE} AS mimalloc

ARG MIMALLOC_VERSION

USER 0

RUN apk add --no-cache build-base cmake git
RUN git clone --depth 1 --branch ${MIMALLOC_VERSION} https://github.com/microsoft/mimalloc.git \
    /src/mimalloc

WORKDIR /src/mimalloc/out/release
RUN cmake ../.. && make

###################################################################################################
# Fetch tesseract language data                                                                   #
###################################################################################################

FROM ${BASE_IMAGE} AS tessdata

ARG TESSDATA_VERSION

USER 0

RUN apk add --no-cache curl

WORKDIR /tessdata
RUN curl -fsSLO https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/${TESSDATA_VERSION}/eng.traineddata && \
    curl -fsSLO https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/${TESSDATA_VERSION}/osd.traineddata && \
    printf '%s  %s\n' \
      7d4322bd2a7749724879683fc3912cb542f19906c83bcc1a52132556427170b2 eng.traineddata \
      9cf5d576fcc47564f11265841e5ca839001e7e6f38ff7f7aacf46d15a96b00ff osd.traineddata \
    | sha256sum -c -

###################################################################################################
# Build the web UI                                                                                #
###################################################################################################

FROM --platform=$BUILDPLATFORM ${NODE_IMAGE} AS ui

WORKDIR /ui

COPY --from=src /src/ui/package.json /src/ui/package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY --from=src /src/ui/ ./
RUN npm run build -- --outDir /ui/dist

###################################################################################################
# Builder: compilers live here only, never in the final image                                    #
###################################################################################################

FROM ${BUILDER_IMAGE} AS builder
USER 0

RUN apk add --no-cache build-base git python-3.12-dev && \
    adduser -D -H -u 1001 -G root -h /opt/app-root/src -s /sbin/nologin default && \
    uv venv --python /usr/bin/python3.12 /opt/app-root && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    chmod -R g=u /opt/app-root

USER 1001
WORKDIR /opt/app-root/src

ENV \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/bin:$PATH \
    OMP_NUM_THREADS=4 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    UV_PYTHON=/usr/bin/python3.12 \
    UV_PYTHON_DOWNLOADS=never \
    UV_COMPILE_BYTECODE=1 \
    UV_NO_CACHE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/app-root \
    DOCLING_SERVE_ARTIFACTS_PATH=/opt/app-root/src/.cache/docling/models

ARG UV_SYNC_EXTRA_ARGS
ARG UV_SYNC_EXCLUDE_ARGS="--no-install-package peft --no-install-package virtualenv --no-install-package tree-sitter-javascript"

COPY --from=src --chown=1001:0 /src/pyproject.toml /src/uv.lock ./
RUN umask 002 && \
    UV_SYNC_ARGS="--frozen --no-install-project --no-dev --all-extras ${UV_SYNC_EXCLUDE_ARGS}" && \
    uv sync ${UV_SYNC_ARGS} ${UV_SYNC_EXTRA_ARGS} --no-extra flash-attn && \
    FLASH_ATTENTION_SKIP_CUDA_BUILD=TRUE uv sync ${UV_SYNC_ARGS} ${UV_SYNC_EXTRA_ARGS} --no-build-isolation-package=flash-attn

ARG MODELS_LIST="layout tableformer picture_classifier rapidocr easyocr"
RUN echo "Downloading models..." && \
    HF_HUB_DOWNLOAD_TIMEOUT="90" \
    HF_HUB_ETAG_TIMEOUT="90" \
    docling-tools models download -o "${DOCLING_SERVE_ARTIFACTS_PATH}" ${MODELS_LIST} && \
    chmod -R g=u ${DOCLING_SERVE_ARTIFACTS_PATH}

COPY --from=src --chown=1001:0 /src/docling_serve ./docling_serve
COPY --from=ui --chown=1001:0 /ui/dist ./docling_serve/ui_static

RUN umask 002 && \
    uv sync --frozen --no-dev --all-extras ${UV_SYNC_EXCLUDE_ARGS} ${UV_SYNC_EXTRA_ARGS} && \
    rm -rf /opt/app-root/lib/python3.12/site-packages/ray/jars

###################################################################################################
# Runtime                                                                                         #
###################################################################################################

FROM ${BASE_IMAGE}
USER 0

RUN apk add --no-cache \
    glibc-locale-posix \
    libstdc++ \
    libgcc \
    libgomp \
    libatomic \
    libglvnd \
    glib && \
    apk del --no-cache py3-pip && \
    rm -f /tmp/os-packages.txt && \
    adduser -D -H -u 1001 -G root -h /opt/app-root/src -s /sbin/nologin default && \
    mkdir -p /opt/app-root/src && \
    chown -R 1001:0 /opt/app-root && \
    chmod -R g=u /opt/app-root

COPY --from=mimalloc /src/mimalloc/out/release/libmimalloc.so /usr/local/lib/libmimalloc.so
COPY --from=tessdata /tessdata/ /usr/share/tesseract/tessdata/
COPY --from=builder --chown=1001:0 /opt/app-root /opt/app-root

USER 1001
WORKDIR /opt/app-root/src

ENV \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/bin:$PATH \
    OMP_NUM_THREADS=4 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    TESSDATA_PREFIX=/usr/share/tesseract/tessdata/ \
    DOCLING_SERVE_ARTIFACTS_PATH=/opt/app-root/src/.cache/docling/models \
    LD_PRELOAD=/usr/local/lib/libmimalloc.so

EXPOSE 5001

CMD ["docling-serve", "run"]
