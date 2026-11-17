
ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
FROM ${BASE_IMAGE}

ARG UPSTREAM_TAG=mainline
RUN apk add --no-cache nginx-${UPSTREAM_TAG}

RUN adduser -D -u 101 nginx
RUN mkdir -p /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html && \
    chown -R 101:101 /var/log/nginx /etc/nginx/conf.d /usr/share/nginx

USER 101
