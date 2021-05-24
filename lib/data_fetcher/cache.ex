defmodule DataFetcher.Cache do
  use Task

  @default_storage DataFetcher.CacheStorage.Ets
  @storage Application.compile_env(:data_fetcher, :storage, @default_storage)

  def start_link(opts),
    do:
      Task.start_link(fn ->
        @storage.init(opts)
      end)

  def put(name, result),
    do: @storage.put(name, result)

  def get(name),
    do: @storage.get(name)
end
