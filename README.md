# DataFetcher

DataFetcher is a library that can ease fetch-and-cache jobs for Elixir projects.

**Caution:** It's currently under development and not published yet.

## Features

* Periodic data fetching
* Automatically retrying on failures
* High performance (backed by [ETS][] and [persistent_term][])

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
  def fetch,
    do: fetch_my_data_from_remote_source()

  defp fetch_my_data_from_remote_source do
    # if successful:
    {:ok, %{foo: "bar"}}
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
      my_fetcher_spec(),
      ...
    ]

    opts = [strategy: :one_for_one, name: MySupervisor]
    Supervisor.start_link(children, opts)
  end

  defp my_fetcher_spec,
    do: {
        DataFetcher,
        name: :my_fetcher,
        fetcher: &MyWorker.fetch/1,
        interval: :timer.minutes(20)
      }
end
```

There you go! Every 20 minutes you'll have fresh data pulled from your data source.

### 3. Get fetched result

Whenever you need the result, you can call `DataFetcher.result/1`.

```elixir
DataFetcher.result(:my_fetcher)
```

## Selecting cache storage adapter

By default, [ETS][] is used as the cache storage. ETS is performant but if you need better performance at reading the data by avoiding copying messages between processes, you can switch to [persistent_term][] which does no copying when reading the result. However, the trade-off is it is slower on writing. Developers can choose which fits their need better according to the scenario.

```elixir
# file: config/config.exs
# with ETS (by default)
config :data_fetcher, :cache_storage, DataFetcher.CacheStorage.Ets

# or with persistent_term
config :data_fetcher, :cache_storage, DataFetcher.CacheStorage.PersistentTerm
```

[ETS]: https://erlang.org/doc/man/ets.html
[persistent_term]: https://erlang.org/doc/man/persistent_term.html
