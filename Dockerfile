FROM node:lts-alpine

WORKDIR /contents
ENV LC_ALL=ja_JP.UTF-8

# キャッシュを削除してイメージサイズを削減
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# npm install を1回にまとめてレイヤーを削減
RUN npm install -g npm@latest \
 && npm init --yes \
 && npm install -g \
    zenn-cli@latest \
    textlint \
    textlint-rule-preset-ja-technical-writing \
    textlint-rule-no-dropping-the-ra \
    textlint-rule-no-mix-dearu-desumasu \
    textlint-rule-spellcheck-tech-word \
    textlint-filter-rule-comments \
    textlint-rule-preset-ja-spacing \
    textlint-rule-ja-no-redundant-expression \
    textlint-rule-ja-unnatural-alphabet \
 && npm cache clean --force

ENTRYPOINT ["/usr/local/bin/npx"]