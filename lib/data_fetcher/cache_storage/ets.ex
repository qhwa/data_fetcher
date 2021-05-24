defmodule DataFetcher.CacheStorage.Ets do
  @moduledoc """
  Ets storage adapter
  """

  @behaviour DataFetcher.CacheStorage

  @impl true
  def init(opts) do
    table = table_name(opts[:name])

    Task.start_link(fn ->
      # for ets we need a process to keep the link to it
      :ets.new(table, [:set, :public, :named_table])
      :timer.sleep(:infinity)
    end)

    :ok
  end

  @impl true
  def put(name, result) do
    true = :ets.insert(table_name(name), {:result, result})
    :ok
  end

  @impl true
  def get(name) do
    table = table_name(name)

    with tid when is_reference(tid) <- :ets.whereis(table),
         [{:result, result}] <- :ets.lookup(table, :result) do
      {:ok, result}
    else
      _ -> nil
    end
  end

  defp table_name(name),
    do: Module.concat(__MODULE__, name)
end
