# Builder stage
FROM elixir:1.9.4 as builder

RUN mix local.hex --force \
 && mix local.rebar --force

RUN mkdir -p /cashier
WORKDIR /cashier

COPY . .

RUN mix deps.get && \
    mix deps.compile && \
    mix docs

# Default stage
FROM httpd:2.4
COPY --from=builder /cashier/doc /usr/local/apache2/htdocs/

CMD [ "httpd-foreground" ]
