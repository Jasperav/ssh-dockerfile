FROM rust:1.65 AS builder

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

WORKDIR app
COPY . .
RUN mkdir -p /root/.ssh
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN --mount=type=ssh cargo build --release

FROM debian:buster-slim
COPY --from=builder ./target/release/docker ./target/release/docker

CMD ["./release/server"]