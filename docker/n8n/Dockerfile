FROM n8nio/n8n:1.110.0

ARG TYPST_VERSION=0.13.1

USER root

RUN apk add --no-cache coreutils curl xz

RUN curl -L -o typst.tar.xz "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz" && \
    tar -xf typst.tar.xz && \
    mv typst-*/typst /usr/local/bin/ && \
    chmod +x /usr/local/bin/typst && \
    rm typst.tar.xz && \
    rm -r typst-*/

USER node
