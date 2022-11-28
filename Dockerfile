FROM rust:1.65 AS builder
WORKDIR app
COPY . .
RUN cargo build --release

FROM debian:buster-slim
COPY --from=builder ./target/release/docker ./target/release/docker

CMD ["./release/server"]