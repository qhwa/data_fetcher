defmodule DataFetcher.Worker do
  use Task

  def start_link(opts) do
    fetcher = build_fetcher(opts[:fetcher])
    name = Keyword.fetch!(opts, :name)

    Task.start_link(fn ->
      # let it crash and be restarted if not successful
      {:ok, result} = fetcher.()

      result
      |> update(name)
      |> broadcast(name)
    end)
  end

  defp build_fetcher({m, f, a}) when is_atom(m) and is_atom(f) and is_list(a) do
    fn ->
      apply(m, f, a)
    end
  end

  defp build_fetcher(lambda) when is_function(lambda, 0),
    do: lambda

  defp build_fetcher(module) when is_atom(module),
    do: build_fetcher({module, :fetch, []})

  defp update(result, name) do
    DataFetcher.Cache.put(name, result)
    result
  end

  defp broadcast(result, name) do
    DataFetcher.Result.fetched(name, result)
    result
  end
end
