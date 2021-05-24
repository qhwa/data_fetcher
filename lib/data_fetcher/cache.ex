defmodule DataFetcher.Cache do
  use Agent

  @default_storage Application.compile_env(
                     :data_fetcher,
                     :cache_storage,
                     DataFetcher.CacheStorage.Ets
                   )

  def start_link(opts) do
    storage = Keyword.get(opts, :cache_storage, @default_storage)

    Agent.start_link(
      fn ->
        storage.init(opts)
        storage
      end,
      name: via_tuple(opts[:name])
    )
  end

  defp via_tuple(name),
    do: {:via, Registry, {DataFetcher.Registry.registry_name(name), :cache}}

  def put(name, result),
    do: storage_adapter(name).put(name, result)

  def get(name),
    do: storage_adapter(name).get(name)

  defp storage_adapter(name),
    do: Agent.get(via_tuple(name), & &1)
end
