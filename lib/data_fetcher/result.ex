defmodule DataFetcher.Result do
  use GenServer
  require Logger

  def child_spec(name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :transient
    }
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  defp via_tuple(name) do
    reg_name = DataFetcher.Registry.registry_name(name)
    {:via, Registry, {reg_name, :result}}
  end

  def get(name) do
    case get_result_from_cache(name) do
      {:ok, result} ->
        result

      nil ->
        GenServer.call(via_tuple(name), :get)
    end
  end

  defp get_result_from_cache(name),
    do: DataFetcher.Cache.get(name)

  def fetched(name, result) do
    Logger.debug(["Fetcher ", inspect(name), " finishes, result: ", inspect(result)])
    GenServer.cast(via_tuple(name), {:fetched, result})
  end

  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call(:get, from, callers),
    do: {:noreply, [from | callers]}

  @impl true
  def handle_cast({:fetched, result}, callers) do
    notify_callers(callers, result)
    {:stop, :normal, callers}
  end

  defp notify_callers(callers, result),
    do: for(pid <- callers, do: GenServer.reply(pid, result))
end
