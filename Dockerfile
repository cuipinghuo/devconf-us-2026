FROM alpine:latest

RUN apk add --no-cache \
    bash \
    tree \
    jq \
    bat \
    curl \
    ca-certificates

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Install ec (Conforma CLI)
RUN wget https://github.com/conforma/cli/releases/latest/download/ec_linux_amd64 && \
    mv ec_linux_amd64 /usr/local/bin/ec && \
    chmod +x /usr/local/bin/ec

WORKDIR /demos

COPY demo1/ /demos/demo1/
COPY demo2/ /demos/demo2/
COPY demo3/ /demos/demo3/
COPY demo4/ /demos/demo4/
COPY helpers.sh /demos/

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
