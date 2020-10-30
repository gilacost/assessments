#BUILD STAGE
ARG ALPINE_VERSION=3.11.5
ARG ELIXIR_VSN=1.10.2
FROM elixir:${ELIXIR_VSN}-alpine as builder

ENV MIX_ENV=prod GIT_VERSION=2.24.3-r0 NCURSES_VERSION=6.1_p20200118-r4

RUN apk --no-cache add git=$GIT_VERSION #\
                       # ncurses=$NCURSES_VERSION && \
    rm -rf /var/cache/apk/*

WORKDIR /tmp

RUN mix local.rebar --force && mix local.hex --force

COPY . .

RUN mix deps.get && mix deps.compile && mix compile
RUN mix release puffel

#RELEASE STAGE
FROM alpine:${ALPINE_VERSION} as runtime

COPY --from=builder /usr/lib/libncursesw.* /usr/lib/
COPY --from=builder /tmp/_build/*/rel/puffel /opt/

HEALTHCHECK --interval=5m --timeout=3s \
  CMD exit $(/opt/bin/puffel rpc "Puffel.healtcheck()" 2>&1 || 1)

CMD ["version"]
ENTRYPOINT ["/opt/bin/puffel"]
