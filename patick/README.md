# Patick 🅿️

## Installation 🛠

In order to be able to run the project locally, you need to have installed
[docker](https://docs.docker.com/get-docker/) and
[asdf](https://github.com/asdf-vm/asdf) with elixir and erlang plugins.

Install language versions.`asdf install`.

And then run postgres service, create the repo and run the migrations:

```bash
docker-compose up -d && \
mix ecto.create && \
mix ecto.migrate
```

## Run the service ▶️

There is not stub for the `Patick` repo, so you need to have postgres service
running in order to run the application. You can do it with `iex -S mix`.

If you want to generate the release, you can do it with
`MIX_ENV=YOUR_ENV mix release patick`. Then you can run the release
`_build/YOUR_ENV/rel/patick/bin/patick start_iex`. To list all commands just
run `_build/YOUR_ENV/rel/patick/bin/patick`.

## Testing ✅

To run the tests you just need to have postgres stared as deamon in the
background. And then run `mix test`.

This is possible to the alias in `mix.exs` file that recreates the DB and run
all migrations on every run.

```elixir
...
  defp aliases do
    [
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
...
```

## CI 🚥

A [github action](/github/workflows/test.yml) has been added to ensure that the
code will be formatted and tested.

```yaml
...
      - name: Get Dependencies
        run: mix deps.get

      - name: Check Source Code Formatting
        run: mix format --check-formatted

      - name: Run Tests
        run: mix test --trace

      - name: Run Dialyzer
        run: mix dialyzer
...
```

There are two steps that cache the `plts` and the dependencies in order to speed
up the CI jobs.

## Terraform 🏗

One terraform configuration [script](/terraform/main.tf) has been implemented
to create the heroku resuorces. After creation continuous delivery has been
enabled and the wait for CI checkbox opted in.
