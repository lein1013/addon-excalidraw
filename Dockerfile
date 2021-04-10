ARG BUILD_FROM=homeassistant/amd64-base:latest
FROM $BUILD_FROM as buildha

ENV LANG C.UTF-8

WORKDIR /
RUN apk add git
RUN git clone https://github.com/excalidraw/excalidraw.git
WORKDIR excalidraw

FROM node:14-alpine AS build

WORKDIR /opt/node_app

COPY --from=buildha excalidraw/package.json ./
COPY --from=buildha excalidraw/yarn.lock ./
RUN yarn --ignore-optional

ARG NODE_ENV=production

COPY --from=buildha excalidraw/ .
RUN yarn build:app:docker

FROM nginx:1.17-alpine

COPY --from=build /opt/node_app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1

RUN echo "addon excalidraw healthcheck"

#WORKDIR /
#COPY start.sh /app/start.sh
#ENTRYPOINT ["/app/start.sh"]

#LABEL io.hass.version="VERSION" io.hass.type="addon" io.hass.arch="armhf|aarch64|i386|amd64"


# docker build -t local/addon-excalidraw .