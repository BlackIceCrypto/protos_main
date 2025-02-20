FROM rust:latest AS builder

RUN apt update && \
    apt install -y build-essential pkg-config libssl-dev protobuf-compiler && \
    mkdir /root/.nexus && \
    cd /root/.nexus && \
    git clone https://github.com/nexus-xyz/network-api && \
    cd network-api && \
    git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1)

WORKDIR /root/.nexus/network-api/clients/cli

RUN cargo build --release --bin nexus-network

FROM ubuntu:noble

RUN apt update && \
    apt install -y ca-certificates pkg-config libssl-dev && \
    mkdir /root/.nexus

COPY --from=builder /root/.nexus/network-api/clients/cli/src /root/.nexus/src
COPY --from=builder /root/.nexus/network-api/clients/cli/target/release/nexus-network /root/.nexus/nexus-network

WORKDIR /root/.nexus

COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]