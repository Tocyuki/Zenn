FROM node:15.3.0-alpine3.10

WORKDIR /contents
ENV LC_ALL=ja_JP.UTF-8

RUN apk update \
 && npm init --yes \
 && npm install -g zenn-cli@latest

ENTRYPOINT ["/usr/local/bin/npx"]