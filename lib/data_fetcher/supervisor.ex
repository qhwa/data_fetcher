defmodule DataFetcher.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @impl true
  def init(opts) do
    children = [
      {DataFetcher.WorkersSupervisor, opts}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
