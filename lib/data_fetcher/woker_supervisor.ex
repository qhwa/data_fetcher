defmodule DataFetcher.WorkerSupervisor do
  use DynamicSupervisor

  def start_link(opts),
    do:
      DynamicSupervisor.start_link(
        __MODULE__,
        opts,
        name: supervisor_name(opts[:name])
      )

  def supervisor_name(name),
    do: Module.concat(__MODULE__, name)

  def spawn_worker(name, child_spec),
    do:
      DynamicSupervisor.start_child(
        supervisor_name(name),
        child_spec
      )

  @impl true
  def init(_opts),
    do: DynamicSupervisor.init(strategy: :one_for_one)
end
