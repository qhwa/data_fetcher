defmodule DataFetcher do
  @moduledoc """
  An abstraction on periodic data fetching jobs.
  """

  def child_spec(opts) do
    DataFetcher.Supervisor.child_spec(opts)
  end

  def result_from_ets(name) do
    :ets.lookup(ets_table_name(name), name)
  end

  def ets_table_name(_name),
    do: Application.get_env(:data_fetcher, :ets_table_name, __MODULE__)

  @doc """
  Get result of the fetch.

  ## Parameters

  - `name` - atom, the identifier of the fetch job

  ## Returns

  - any

  If the fetch job is initialized and in progress, it blocks
  until the fetch finishes.
  """

  @spec result(fetcher_name: atom) :: any

  def result(name),
    do: DataFetcher.Result.get(name)
end
