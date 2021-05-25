defmodule DataFetcher.Cache do
  @moduledoc false

  use Task

  @default_storage Application.compile_env(
                     :data_fetcher,
                     :cache_storage,
                     DataFetcher.CacheStorage.Ets
                   )

  def start_link(opts) do
    storage = Keyword.get(opts, :cache_storage, @default_storage)

    define_storage_module(opts[:name], storage)

    Task.start_link(fn ->
      storage.init(opts)
    end)
  end

  defp define_storage_module(name, storage) do
    module_definition(name, storage)
    |> Code.eval_quoted()
  end

  defp module_definition(name, storage) do
    quote do
      defmodule unquote(storage_mod(name)) do
        def adapter, do: unquote(storage)
      end
    end
  end

  defp storage_mod(name),
    do: Module.concat([__MODULE__, StorageDef, name])

  def put(name, result),
    do: storage_adapter(name).put(name, result)

  def get(name),
    do: storage_adapter(name).get(name)

  defp storage_adapter(name),
    do: storage_mod(name) |> apply(:adapter, [])
end
