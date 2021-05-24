defmodule DataFetcher.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    name = opts[:name]
    unless name, do: raise("`:name` option is required to start a data fetcher")

    Supervisor.start_link(__MODULE__, opts, name: supervisor_name(name))
  end

  def supervisor_name(name) do
    Module.concat(__MODULE__, name)
  end

  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)

    children = [
      {DataFetcher.Registry, name},
      {DataFetcher.Cache, opts},
      {DataFetcher.Result, name},
      {DataFetcher.WorkerSupervisor, opts},
      {DataFetcher.Scheduler, opts}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
