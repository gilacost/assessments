#!/bin/sh

mix ecto.drop
mix ecto.create
mix ecto.migrate
mix run priv/load_categories.ex
