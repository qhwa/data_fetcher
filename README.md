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

The difference could be tiny when the data size is small but significant for bigger data. Here's the performance test result on my laptop:

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
huge_list_pt        203.42 K        4.92 μs   ±391.72%        4.14 μs       10.16 μs
small_atom_pt       175.81 K        5.69 μs   ±332.92%        4.15 μs       22.42 μs
small_atom_ets       76.47 K       13.08 μs   ±170.09%       14.87 μs       43.94 μs
huge_list_ets        0.125 K     8030.95 μs    ±46.61%     5724.22 μs    19444.12 μs

Comparison: 
huge_list_pt        203.42 K
small_atom_pt       175.81 K - 1.16x slower +0.77 μs
small_atom_ets       76.47 K - 2.66x slower +8.16 μs
huge_list_ets        0.125 K - 1633.66x slower +8026.03 μs
```

[ETS]: https://erlang.org/doc/man/ets.html
[persistent_term]: https://erlang.org/doc/man/persistent_term.html
