# DataFetcher

DataFetcher is a library that can ease fetch-and-cache jobs for Elixir projects.

**Caution:** It's currently under development and not published yet.

## Features

* Periodic data fetching
* Automatically retrying on failures
* High performance (backed by [ets](https://erlang.org/doc/man/ets.html))
* Metrics (on the roadmap)

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

### 1. Define a fetching worker

```elixir
defmodule MyWorker do
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
  def start(_type, _args) do
    children = [
      {
        DataFetcher,
        name: :my_fetcher,
        fetcher: &MyWorker.fetch/1,
        interval: :timer.minutes(20)
      }, # <- add into your supervisor tree
      ...
    ]

    opts = [strategy: :one_for_one, name: MySupervisor]
    Supervisor.start_link(children, opts)
  end
end
```

There you go! Every 20 minutes you'll have fresh data pulled from your data source.

### 3. Get fetched result

Whenever you need the result, you can call `DataFetcher.result/1`.

```elixir
DataFetcher.result(:my_fetcher)
```

