## Things done

For this exercise I created a private repo named
[vdp](https://github.com/gilacost/vdp) hosted in **github**. Once the repo was
created I cloned the backend-test repo and added the vdp repo as remote, so you
shall find your commits in the history.

After adding the remote I generated a new elixir supervised application within
the ~vdp~ repo with `mix new --sup ./`.

Once the application was generated I decided to use `plug_cowboy` to set up a
minimal API with not too much configuration and the minimum scaffolding. While
doing this I realised that the formatter was behaving weirdly, in the router was
putting plug calls between parenthesis and the docs examples were without. To
sort this I changed the formatter configuration to include the `:plug` and
`:ecto` rules. Check it [here](./formatter.exs)

Every time that I checked the endpoint with `curl` and `jq` like:

```bash
curl http://localhost:8080/search/data-categories\?q=P | jq
```

When the endpoint was up I tried to build the tree structure after parsing the
CSV, but after some struggling, I decided to store the CSV data into a Postgres
and then think about a simple way to query the vdp categories.

To do this I used a simple `docker-compose.yml` that I have used in many other
projects that just spins up a Postgres service. Once I had the Postgres I added
the `csv`, `ecto_sql` and `postgrex` dependencies for parsing and storing the
data into Postgres. I thought that ecto will ease querying by ID, inserting new
data and that I could also take advantage of the migrations generator.

Once that the data was in Postgres I decided to add a temporary service called
adminer that allowed me to run queries directly to Postgres through a web
client.

```yaml
...
    networks:
      - backend
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
    networks:
      - backend

networks:
  backend:
...
```

I saw that to translate this to `Ecto.Query` DSL was going to be quite
cumbersome so I decided to use [AyeSql](https://github.com/alexdesousa/ayesql).
This is a library that allows you to write raw SQL while interpolating
variables, [see the raw sql](./lib/vdp/queries.sql).

After this I wrote the function in the vdp module that builds the category tree
and the categories ids for building the hyperlinks.

Once everything was working I thought about using benchee to run some
benchmarcks because I have been wanting to use it for a while now, but I thought
that would take too much time so I decided that `wrk` would do the job to test
the concurrency.

With `wrk` I realised that this application could only resists 200 req/s
more-less. And then I decided to use `ets` for caching the search and avoid
querying the database for the same search. Then the application was able to
resists 17000 req/s.

## Instructions to stress test the application
To be able to stress the application you need to have
[wrk](https://github.com/wg/wrk) installed. For mac users just run
`brew install wrk`.

```bash
docker-compose up -d
./refresh_db.sh
iex -S mix
wrk -t1 -c1000 -d10s http://localhost:8090/search/data-categories\?q\=Au
```

## What I would've done different

- write more docs like I normally do in my projects
([lettuce](https://github.com/gilacost/lettuce/blob/master/lib/lettuce/config.ex))
- write tests
- ex_doc
- invalidate cache
- avoid using ecto
- use dyalizer
- credo
- pre-commit hooks ( command
- research more db connections
- play a bit with becnhee
