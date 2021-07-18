FROM ubuntu:20.04

COPY toolchain /toolchain

RUN \
    /toolchain/apt.sh \
    && rm -rf /var/lib/apt/lists/* \
    && /toolchain/bazel.sh \
    && /toolchain/spark.sh \
    && useradd --create-home --user-group bookie \
    && chown bookie:bookie /opt/spark

USER bookie
WORKDIR /home/bookie
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/toolchain/entrypoint.sh"]

LABEL \
    org.opencontainers.image.authors="ashwin.madavan@gmail.com" \
    org.opencontainers.image.description="A Spark installation on Ubuntu 20.04 LTS." \
    org.opencontainers.image.documentation="https://wager.help" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/wager/bookie" \
    org.opencontainers.image.title="Wager Runtime" \
    org.opencontainers.image.vendor="Wager"
