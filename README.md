# DataFetcher

DataFetcher is a library that can ease fetch-and-cache jobs for Elixir projects.

**Caution:** It's currently under development and not published yet.

## Features

* Periodic data fetching
* Automatically retrying
* Custom `success` and `error` callbacks
* High performance (backed by [ets](https://erlang.org/doc/man/ets.html))

## Installation

The package can be installed
by adding `data_fetcher` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:data_fetcher, github: "qhwa/data_fetcher"}
  ]
end
```

## Usage

### 1. Define a fetcher

```elixir
defmodule MyDataFetcher do

  use DataFetcher, interval: :timer.minutes(20)

  @impl true
  def fetch(_context) do
    fetch_my_data_from_remote_source()
  end
end
```

### 2. Add in the supervisor tree

```elixir
# lib/my_app/application.ex
defmodule MyApp.Application do
  use Application

  @impl true
  def st
