ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base
FROM ${BASE_IMAGE}

ARG NODE_VERSION=24
ENV NVM_DIR=/opt/nvm

RUN apk add --no-cache nvm bash libatomic \
 && mkdir -p "$NVM_DIR" \
 && bash -c '. /usr/share/nvm/nvm.sh \
      && nvm install "$NODE_VERSION" \
      && nvm alias default "$NODE_VERSION" \
      && ln -s "$NVM_DIR/versions/node/$(nvm version default)" "$NVM_DIR/current"'

ENV PATH="$NVM_DIR/current/bin:$PATH"
RUN node --version && npm --version
