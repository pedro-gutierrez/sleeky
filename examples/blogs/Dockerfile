FROM elixir:1.12-alpine as builder
RUN apk add --no-cache --update bash git openssl
ENV MIX_ENV=prod
COPY config ./config
COPY lib ./lib
COPY mix.exs .
COPY mix.lock .
RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix release

FROM alpine:3
RUN apk add --no-cache --update bash openssl
WORKDIR /app
COPY --from=builder _build/prod/rel/blog/ .
CMD ["/app/bin/blog", "start"]
