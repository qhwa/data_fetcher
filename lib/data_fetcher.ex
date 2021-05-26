defmodule DataFetcher do
  @moduledoc """
  An abstraction on periodic data fetching jobs.

  ## Features

  * Periodic data fetching
  * Automatically retrying on failures
  * High performance (backed by `:ets` and `:persistent_term`)
  * Consistent api for getting the result, even during the first fetching 
  * No blocking your application from booting up
  """

  @type fetcher_def :: (() -> {:ok, any}) | mfa() | module()
  @type option ::
          {:name, atom}
          | {:cache_storage, atom}
          | {:fetcher, fetcher_def}
          | {:interval, ms :: non_neg_integer}

  @spec child_spec([option]) :: Supervisor.child_spec()

  @doc """
  Build the supervisor child spec to start the data_fetcher.

  ## Supported options

  - `:name` - The identity of the job, should be unique.
  - `:fetcher` - Definition of how data is fetched from the source. A fetcher must return `{:ok, data}` if successful.
  - `:interval` - A value in `ms` indicating how long it waits until next fetching. The exuction time will not affect the interval, neither does the failure of a fetching. 10 minutes by default.
  - `:cache_storage` - What cache storage adapter to store the data. Ets by default. See Cache Storage section below.

  ## Cache Storage

  When data is fetched from the source, it will be saved in the cache storage. By default it uses an ETS table so that later reads can directly read from the ETS table. This is adaquate for most cases unless the data size is huge. In such large data cases, copying and messaging between processes can be expensive and have performance penalties.

  If the data rarely or never changes, you can improve the performance in such cases by employing the persistent_term adapter, which is faster at reading no matter how large the data is. Be aware that on the other hand, writing into the cache storage is slower for persitent_term because global GC will happen for every write.

  You can change the adapter globally with:

  ```elixir
  config :data_fetcher, :cache_storage, DataFetcher.CacheStorage.PersistentTerm
  ```

  or for each fetcher with the `cache_storage` option mentioned above.

  ## Example

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
  """
  def child_spec(opts) do
    DataFetcher.Supervisor.child_spec(opts)
  end

  @doc """
  Get result of the fetch.

  ## Parameters

  - `name` - atom, the identifier of the fetch job

  ## Returns

  - any

  When called, if the data is still being fetched at the first round,
  it will wait until the data is successfully fetched before returning
  the result. Otherwise, data is read from the cache and returned
  immediately.

  ## Example

  ```elixir
  iex> opts = [
  ...>   name: :my_fetcher,
  ...>   fetcher: fn -> {:ok, %{foo: 1}} end
  ...> ]
  ...>
  ...> {:ok, _} = Supervisor.start_link([
  ...>     {DataFetcher, opts}
  ...>   ], strategy: :one_for_one)
  ...>
  ...> DataFetcher.result(:my_fetcher)
  %{foo: 1}
  ```
  """

  @spec result(fetcher_name :: atom) :: any

  def result(name),
    do: DataFetcher.Result.get(name)
end
