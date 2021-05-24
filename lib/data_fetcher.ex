defmodule DataFetcher do
  @moduledoc """
  An abstraction on periodic data fetching jobs.
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

  If the fetch job is initialized and in progress, it blocks
  until the fetch finishes.
  """

  @spec result(fetcher_name :: atom) :: any

  def result(name),
    do: DataFetcher.Result.get(name)
end
