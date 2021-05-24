defmodule DataFetcher.Cache do
  use Task, restart: :permanent

  def start_link(name),
    do: Task.start_link(__MODULE__, :run, [name])

  def run(name) do
    :ets.new(DataFetcher.ets_table_name(name), [:set, :public, :named_table])

    :timer.sleep(:infinity)
  end
end
