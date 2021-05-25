# DataFetcher 

![CI status](https://github.com/qhwa/data_fetcher/workflows/CI/badge.svg)
![coverage](https://coveralls.io/repos/github/qhwa/data_fetcher/badge.svg?branch=master)

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

### 3. Add in the supervisor tree

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

### 2. Define a fetching worker

```elixir
defmodule MyWorker do
  def fetch do
    # maybe do some networking
    # if successful:
    {:ok, %{foo: "bar"}}
  end
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

The difference could be tiny when the data size is small but huge for bigger data. Here's the performance test result on my laptop:

```sh
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-10710U CPU @ 1.10GHz
Number of Available Cores: 12
Available memory: 15.31 GB
Elixir 1.12.0
Erlang 24.0

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 28 s

Benchmarking huge_list_ets...
Benchmarking huge_list_pt...
Benchmarking small_atom_ets...
Benchmarking small_atom_pt...

Name                     ips        average  deviation         median         99th %
huge_list_pt        275.56 K        3.63 μs  ±1279.66%        2.63 μs        5.50 μs
small_atom_pt       271.58 K        3.68 μs  ±1168.24%        2.63 μs        6.18 μs
small_atom_ets      239.30 K        4.18 μs  ±1033.83%        3.10 μs        5.90 μs
huge_list_ets       0.0668 K    14963.26 μs    ±37.72%    11187.58 μs    28818.89 μs

Comparison: 
huge_list_pt        275.56 K
small_atom_pt       271.58 K - 1.01x slower +0.0532 μs
small_atom_ets      239.30 K - 1.15x slower +0.55 μs
huge_list_ets       0.0668 K - 4123.22x slower +14959.63 μs
```

In conclusion, using [ETS][] is good enough unless your data rarely or never changes and is very large.

[ETS]: https://erlang.org/doc/man/ets.html
[persistent_term]: https://erlang.org/doc/man/persistent_term.html
