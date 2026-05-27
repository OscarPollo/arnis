# syntax=docker/dockerfile:1.7

FROM rust:bookworm AS builder
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libssl-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY Cargo.toml Cargo.lock build.rs ./
COPY src ./src
COPY assets ./assets
COPY tests ./tests

RUN cargo build --release --no-default-features --features bedrock

FROM debian:bookworm-slim AS runtime
WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libssl3 curl wget \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /cache /workspace/output

ENV XDG_CACHE_HOME=/cache
VOLUME ["/cache", "/workspace/output"]

COPY --from=builder /app/target/release/arnis /usr/local/bin/arnis

ENTRYPOINT ["/usr/local/bin/arnis"]
CMD ["--help"]
