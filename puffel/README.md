# Puffel

This repository contains an elixir minimal application used to prepare myself
for the technical interview with the puffel lads. The idea is to understand
their stack better whist dusting off some skills and learning new ones.

## Table of Contents

* [Simple api creation](#simple-api-creation)
  1. [Ping route](#ping-route)
  2. [Testing flights list](#yesting-flights-list)
* [Moving to postgres](#moving-to-postgres)
  1. [Database parameters and migrations](#database-parameters-and-migrations)
  2. [Deriving ecto schema](#deriving-ecto-schema)
  3. [Updating test alias](#updating-test-alias)
* [Moving to docker](#moving-to-docker)
  1. [DOCKER USEFUL COMMANDS](#docker-useful-commands)
  2. [Local registry](#local-registry)
* [Getting in touch with Google Cloud Platform](#getting-in-touch-with-google-cloud-platform)
  1. [Terraform](#terraform)
  2. [Pub Sub Genserver](#pub-sub-genserver)
  2. [The remote backend](#The-remote-backend)
* [Circle CI](#circle-ci)
  1. [Ading dialyxir](#ading-dialyxir)
  1. [PLTs caching for speeding up builds](#plts-caching-for-speeding-up-builds)

## Simple api creation

The easier way to implement a minimal API is to  use plug_cowboy. This library
allows us to spin up an http web server on a certain port under the application
supervision tree.

**NOTE:** the app had to be created with the `--sup` flag. This will affect also
the mix file that will include a mod to define which application module we
should use as the `entrypoint`. I mention this because I created the app without
the flag and then it was not defined as entry `mod` in the mix file.

The port and the router in the application are defined like this:

```elixir
def start(_type, _args) do
  children = [
    {Plug.Cowboy, scheme: :http, plug: Puffel.Router, options: [port: 4001]}
  ]

  opts = [strategy: :one_for_one, name: Puffel.Supervisor]
  Supervisor.start_link(children, opts)
end
```

More documentation and examples in [plug cowboy](https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html).

### Ping route

In my humble opinion the next natural step after setting up the http server, is
to test that it responds to a request. I always like to have a simple ping route
that will respond a pong.

```elixir
defmodule Puffel.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end
...
```

The easiest way to test that our application can receive and respond to `http`
requests is to make a simple GET request with `curl`.

![curl response to ping](/priv/curl.png)

If no route matches the application will send an `oops` as default response.

### Testing flights list

Now we can add a `flights` route that will respond a Json encoded list with
the available flights, let us write a test that asserts this, we need to add
the `jason` dependency for this purpose.

```elixir
...
test "GET /flights respond a list with available flights JSON encoded" do
  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Puffel.Repo)
  flight = %Puffel.Flight{origin: "Barcelona", destination: "London"}
  Puffel.Repo.insert!(flight)

  conn = conn(:get, "/flights")

  conn = Puffel.Router.call(conn, @opts)
  expected = [%{"id" => 1,  "origin" => "Barcelona", "destination" => "London"}]

  assert conn.state == :sent
  assert conn.status == 200
  assert Jason.decode!(conn.resp_body) == expected
end
...
```

### Moving to postgres

This is not the real use case of puffel, in puffel flights are stored in
postgres ( educated guess ), so let us create a docker-compose that has postgres
as a service and instead of directly respond a hard-coded flights map,
use the flights from the postgres database.

To move to postgres first we need to get the `ecto` and `postgrex` dependencies
and then add a postgres service in the docker-compose.

```yaml
version: "3.1"

services:
  db:
    image: postgres
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 10s
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - 5432:5432
```

Once we have this we can run a `docker-compose up` and or a `docker stack deploy
-c docker-comopse.yml puffel`, both will work. But they are exclusive. To run
the stack deploy we need to init a swarm with `docker swarm init` before
deploying the stack.

### Database parameters and migrations

Once we have postgres up we can define the database connection parameters in
`config/config.exs` like this:

```elixir
...
config :puffel, ecto_repos: [Puffel.Repo]

config :puffel, Puffel.Repo,
  database: "puffel",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"
...
```

We also need to set up the `Puffel.Repo` and add it as a children in the
application supervision tree following the [ecto documentation](https://hexdocs.pm/ecto/Ecto.html)

Once everything is set up if we can create the database and create some
migrations. This migrations will create a flights table and insert a row
with `%Puffel.Flight{origin: "Barcelona", destination: "London"}`, the same that
we had hard-coded as a map.

```elixir
...
def change do
  create table(:flight) do
    add(:origin, :string)
    add(:destination, :string)
  end
end
...
def change do
  flight = %Puffel.Flight{origin: "Barcelona", destination: "London"}
  Puffel.Repo.insert!(flight)
end
...
```

The second migration is not right, I am sure there is a better way of doing
this :). Once we have some data in the database we need to adapt the router to
return the flight queried from the postgres using the ecto repo.

```elixir
...
get "/flights" do
  flight_list = Puffel.Flight |> Ecto.Query.first() |> Puffel.Repo.all()
  send_resp(conn, 200, Jason.encode!(flight_list))
end
...
```

### Deriving ecto schema

In order to be able to json encode an Ecto schema struct directly we can use
`@derive` to specify which json encoder should be used and which fields should
be included in the encoded json.

```elixir
...
@derive {Jason.Encoder, only: [:id, :origin, :destination]}
...
```

We also need to override the alias with additional commands that will drop the
test database, then create it, then run the migrations and then will run the
tests.

### Updating test alias

```elixir
defp aliases do
  [
    test: ["ecto.drop --quiet","ecto.create --quiet", "ecto.migrate", "test"]
  ]
end
```

## Moving to docker

We have something quite similar to the puffel stack in terms of storage. Now
lets **Dockerise** the API and deploy both services. I am studing for the docker
certification, so I prefer to init a **swarm** and then deploy the puffel stack in a
single node cluster with the different services and having api replicated 3
times.

The Dockerfile is quite simple. It uses multi-stage builds using
[apline-elixir](https://hub.docker.com/_/elixir?tab=description)
as builder and once we have the release packaged with `erts` included we copy it
into a clean `apline` to make it as slim as possible. I tried to use scratch in
the from of the RUNTIME stage but it was taking too much, so I decided to put
that in the TODO.

```dockerfile
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

RUN mix deps.get && mix deps.compile && mix compile && mix release puffel

#RELEASE STAGE
FROM alpine:${ALPINE_VERSION}

COPY --from=builder /usr/lib/libncursesw.* /usr/lib/
COPY --from=builder /tmp/_build/*/rel/puffel /opt/

HEALTHCHECK --interval=5m --timeout=3s \
  CMD exit $(/opt/bin/puffel rpc "Puffel.healtcheck()" 2>&1 || 1)

CMD ["version"]
ENTRYPOINT ["/opt/bin/puffel"]
```

I had many problems with [ncurses](https://en.wikipedia.org/wiki/Ncurses), the
release requires the libncursesw shared object. I dont know why yet. But for the
time being works.

**IMPORTANT**
The first time we run the docker-compose we need to manually create the
database. To do so we need to run `mix ecto.create`.

### DOCKER USEFUL COMMANDS

Building the image:
```bash
docker build -t puffel .
```
Checking alpine package information:
```bash
docker run --entrypoint="apk" puffel info ncurses-libs
```
Sleep:
```bash
docker run --entrypoint="sh" puffel -c 'while sleep 3600; do :; done'
```

if we do a docker run without parameters, the default command will show
the version of the puffel application. But we can pass any parameter to the
release like:

```bash
docker run puffel $RELEASE_COMMAND
```

Once we have the `Dockerfile` we can add thew service to the docker-compose and
have both services under the same network.

```yaml
...
    networks:
      - backend
  api:
    image: 127.0.0.1:5000/puffel
    build: .
    command: start
    ports:
      - 80:4001
    networks:
      - backend

networks:
  backend:
```

### Local registry

This is super complicated and does not make sense to implement it like this. I
did it only for learning purposes, in any case it works with `docker-compose up`
and `docker-compose stack deploy`. To deploy this in a local swarm we need to
create a service that will behave as remote registry, more info in [docker docs](https://docs.docker.com/engine/swarm/stack-deploy/)
there is a bash script that contains all the steps in [priv/scripts]("/priv/scripts").

```bash
docker swarm leave --force
docker-compose build
docker swarm init
docker service create --name registry --publish published=5000,target=5000 registry:2
docker-compose push
docker stack deploy --compose-file docker-compose.yml puffel
```

**CURIOSITY**

To deploy a swarm locally you need to build and push the service image using
`docker-compose`.

Once we have all of this we need a way to run the migrations. To do so a
`Puffel.ReleaseTasks` module has been implemented.

This task will be executed every time we start the release. To achieve this the
`rel/env.sh.eex` template that will be used to generate the start script has
been updated. This script is run before the application is started so can't make
an `rpc`.

```bash
#!/bin/sh

set -eo pipefail

case $RELEASE_COMMAND in
  start*)
      /opt/bin/puffel eval 'Puffel.ReleaseTasks.migrate()'
     ;;
   *)
     ;;
esac
```

### Getting in touch with Google Cloud Platform

This is the first time that I `terrafrom` something with GPC provider, so I think
it is nice to share the different steps that I followed in order to create the
two resources needed to test the `PubSub` service.

* having [gcloud] already installed made thinks easier
* GPC terraform provider example uses an `account.json` as credentials
* I Created the `puffel-dev-project` with gcloud
* I had to enable pub/sub service for that particular project
* I generated the json credential from the service accounts page within the
  web-clien

This was a really manual process but maybe because I am not used to GPC :SHRUG

### Terraform

Once this was sorted, creating the topic and the subscriber resources with
`terraform` was fairly easy. The main configuration:

```hcl
provider "google" {
  credentials = file("account.json")
  project     = "puffel-dev"
  region      = "europe-west2"
  zone        = "europe-west2a"
}

resource "google_pubsub_topic" "default" {
  name = "puffel-dev-topic"

  labels = {
    env = "dev"
  }
}

resource "google_pubsub_subscription" "default" {
  name  = "puffel-dev-subscription"
  topic = google_pubsub_topic.default.name

  labels = {
    env = "dev"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
}
```

To test publishing subscribing I first created two elixir scripts in the
APP_ROOT following the documentation from [here](https://github.com/GoogleCloudPlatform/elixir-samples/tree/master/pubsub). You can see them in [priv/scripts](/priv/scripts) folder.
This elixir scripts were run with `mix run` in order to be able to use the
dependencies defined in the mix file.

### Pub Sub Genserver

Once this was tested and a message was published and pulled. I thought it was a
good idea to wrap the publish and the scheduled pulling into a `genserver`, and
store the configuration parameter in its state.

Updates done in the application module:
```elixir
...
project_id = 209_930_607_165
topic_name = "puffel-dev-topic"
subscription_name = "puffel-dev-subscription"

children = [
  {Puffel.Repo, []},
  {Plug.Cowboy, scheme: :http, plug: Puffel.Router, options: [port: 4001]},
  {Puffel.PubSub, [project_id, topic_name, subscription_name]}
]
...
```

PubSub genserver init function:
```elixir
def init(state) do
  {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
  conn = GoogleApi.PubSub.V1.Connection.new(token.token)
  new_state = state ++ [conn]
  schedule_pulling()
  {:ok, new_state}
end
```

There are many parts of this genserver that could be **refactored** but for the
first iteration it does the job.

Enabling the remote backend... account.json in env vars, the service account
does not has permission for google cloud storage
The project to be billed is associated with an absent billing account., accountDisabled
enabling the logs

### The remote backend

I thought that was a nice idea to understand how to enable **remote state** for
a GPC provider. The resource has been created in another folder for **state
isolation**.

It has been a while since last time I used the GPC account, and there was a
problem with the associated billing, this was a problem for the cloud storage
bucket creation. I think this was because this type of resource is not part of
the **free tier**.

![billing problem](/priv/billing_problem.png).

In order to be able to operate with this type of resource I also had to add
the `Sorage admin` role to the service account.

![roles](/priv/roles.png).

## Circle CI

The circle CI login process creates a [yaml](.circleci/config.yml) with some
defaults after detecting that the puffel repo is an elixir project:

```yaml
# Elixir CircleCI 2.0 configuration file
#
# Check https://circleci.com/docs/2.0/language-elixir/ for more details
version: 2
jobs:
  build:
    docker:
      # specify the version here
      - image: circleci/elixir:1.4

      # Specify service dependencies here if necessary
      # CircleCI maintains a library of pre-built images
      # documented at https://circleci.com/docs/2.0/circleci-images/
      - image: circleci/postgres:9.4

    working_directory: ~/repo
    steps:
      - checkout

      # specify any bash command here prefixed with `run: `
      - run: mix deps.get
      - run: mix test
```

In order to make this work we need to change the elixir version to be the same
as the mix file, specify the postgres password as environement variable and
run the mix tasks `local.rebar` and `local.hex`.

```yaml
version: 2
jobs:
  build:
    docker:
      - image: circleci/elixir:1.10.2
      - image: circleci/postgres:9.4
    environment:
      POSTGRES_PASSWORD: postgres
    working_directory: ~/repo
    steps:
      - checkout
      - run: mix local.rebar --force && mix local.hex --force
      - run: mix deps.get
      - run: mix test
```

This configuration makes the CI go green. But this is not what we want, we want
to use our Dockerfile, take advantage of the multi-stage build and ensure
integrity while pushing to our own registry. Luckily circle allows us to do
[so](https://circleci.com/docs/2.0/building-docker-images/).

```elixir
version: 2
jobs:
  build:
    machine: true
    steps:
      - checkout
      # run a postgres with ports opened, this voids network creation
      - run: docker run -e POSTGRES_PASSWORD=postgres --name db -d --rm circleci/postgres:9.4
      # build only the builder stage for testing
      - run: docker build -t puffel-builder:$CIRCLE_BRANCH --target builder .
      # test with builder just built
      - run: docker run --network container:db -e MIX_ENV=test puffel-builder:$CIRCLE_BRANCH mix test
      # build release caching from builder
      - run: docker build -t puffel:$CIRCLE_BRANCH --target runtime --cache-from=puffel-builder:$CIRCLE_BRANCH .
      # show the release version
      - run: docker run puffel:$CIRCLE_BRANCH
```

This is a particular set up that will work only for this scenario but uses many
interesting features from docker.

- attach elixir container to postgres container network
- build certain stage of the docker file with --target
- cache from previous built stage while building the whole dockerfile

### Adding dialyxir

Now that we have the CI in place we can add dialyxir and enforce static typing
analisys for our elxiri application, I normaly do this just after spining up a
new project, because after the project has grown is really hard to fix dialyzer
errors.

### PLTs caching for speeding up builds

First time dialyzer runs plts are added and takes time. In order to speed up
builds we should cache them. To do so we need to change plts saving path in the
mix file:

```elixir
...
dialyzer: [
  plt_add_deps: [:apps_direct],
  plt_add_apps: [:mix],
  plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
]
...
```

And run dialyzer with a volume like this:

```yaml
# run dialyzer with builder target
- run: docker run -v $(pwd)/priv/plts:/tmp/priv/plts -e MIX_ENV=dev puffel-builder:$CIRCLE_BRANCH mix dialyzer
```

## Roadmap

- [x] use remote backend for GPC
- [x] circle ci
- [ ] docker-compose add graphana, prometheus and api services (among the ones from GPC)
- [ ] stress the genserver
- [ ] stress the postgres
- [ ] investigate postgres replication
- [ ] turn on genserver statistics and logging
- [ ] write todos for all docs
- [x] caching plts
- [x] dialyxir
- [ ] push from circleci + autodeploy
- [ ] spellcheck and credo with reviewdog + dependabot
- [ ] test sigterm signal and gracefully stopping
- [ ] think in a way to split the messaging
