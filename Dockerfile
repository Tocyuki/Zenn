FROM node:lts-alpine3.10

WORKDIR /contents
ENV LC_ALL=ja_JP.UTF-8

RUN apk update
RUN npm install -g npm \
 && npm init --yes \
 && npm install -g zenn-cli@latest \
 && npm install -g textlint \
 && npm install -g textlint-rule-preset-ja-technical-writing \
 && npm install -g textlint-rule-no-dropping-the-ra \
 && npm install -g textlint-rule-no-mix-dearu-desumasu \
 && npm install -g textlint-rule-spellcheck-tech-word \
 && npm install -g textlint-filter-rule-comments

ENTRYPOINT ["/usr/local/bin/npx"]