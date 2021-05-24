defmodule DataFetcher.CacheStorage.PersistentTerm do
  @behaviour DataFetcher.CacheStorage

  @impl true
  def init(_opts) do
    :ok
  end

  @impl true
  def put(name, result) do
    :persistent_term.put(key(name), result)
  end

  @impl true
  def get(name) do
    case :persistent_term.get(key(name), :not_found) do
      :not_found ->
        nil

      any ->
        {:ok, any}
    end
  end

  defp key(name),
    do: Module.concat(__MODULE__, name)
end
