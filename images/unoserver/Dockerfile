
# https://github.com/unoconv/unoserver-docker/blob/c81c0729924750e346e237b89f8ff062d7597a35/Dockerfile
# https://github.com/unoconv/unoserver/

ARG BASE_IMAGE=alpine:edge
FROM ${BASE_IMAGE} AS builder
ARG UPSTREAM_TAG

RUN apk add --no-cache py3-pip
RUN pip install --no-cache-dir --break-system-packages \
      --prefix=/install unoserver==${UPSTREAM_TAG}

FROM ${BASE_IMAGE} AS final

ARG UID=100
ARG GID=101
ARG USERNAME=worker

LABEL org.opencontainers.image.title="unoserver-docker"
LABEL org.opencontainers.image.description="Container image that contains unoserver and libreoffice including large set of fonts for file format conversions"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/unoconv/unoserver-docker/blob/main/README.adoc"
LABEL org.opencontainers.image.source="https://github.com/unoconv/unoserver-docker"
LABEL org.opencontainers.image.url="https://github.com/unoconv/unoserver-docker"

WORKDIR /

RUN addgroup -S -g ${GID} ${USERNAME} && adduser -S -u ${UID} -G ${USERNAME} ${USERNAME}

RUN apk upgrade --no-cache
RUN apk add --no-cache \
  bash \
  curl \
  libreoffice-writer \
  libreoffice-calc \
  libreoffice-impress \
  libreoffice-draw

# fonts - https://wiki.alpinelinux.org/wiki/Fonts
RUN apk add --no-cache \
  font-noto font-noto-cjk font-noto-extra \
  terminus-font \
  ttf-font-awesome \
  ttf-dejavu \
  ttf-freefont \
  ttf-hack \
  ttf-inconsolata \
  ttf-liberation \
  ttf-mononoki  \
  ttf-opensans   \
  fontconfig && \
  fc-cache -f

RUN rm -rf /var/cache/apk/* /tmp/*

COPY --from=builder /install /usr

RUN chown -R ${UID}:0 /run && \
  chmod -R g=u /run

USER ${UID}
WORKDIR /home/worker
ENV HOME="/home/worker"

VOLUME ["/data"]
EXPOSE 2003
COPY --chown=${UID}:${GID} entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
