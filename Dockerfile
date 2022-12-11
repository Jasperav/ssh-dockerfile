# Use create_docker_image.bash to create a new build
# https://github.com/rust-lang/cargo/issues/10781#issuecomment-1163829239
FROM rustlang/rust:nightly-bullseye AS builder

WORKDIR app

COPY . .
RUN cargo build --bin hello -Z sparse-registry

FROM debian:11.5
COPY --from=builder ./app/target/debug/hello .

CMD ["./hello"]