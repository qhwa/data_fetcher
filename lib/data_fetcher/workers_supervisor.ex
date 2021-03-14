defmodule DataFetcher.WorkersSupervisor do
  @moduledoc false

  @workers DataFetcher.WorkersSupervisor.Supervisor

  def child_spec(opts) do
    %{
      id: {@workers, opts[:name]},
      start: {
        Supervisor,
        :start_link,
        [children_specs(opts), [strategy: :one_for_one]]
      }
    }
  end

  def children_specs(opts) do
    [
      {DynamicSupervisor, name: dynamic_sup_name(opts), strategy: :one_for_one},
      first_worker_spec(opts)
    ]
  end

  def dynamic_sup_name(opts) do
    name = Keyword.get(opts, :name, Default)
    Module.concat(@workers, name)
  end

  def first_worker_spec(opts) do
    mfa = Keyword.fetch!(opts, :mfa)

    %{
      id: {DataFetcher, :first_process_starter, opts[:name]},
      start: {
        DynamicSupervisor,
        :start_child,
        [
          dynamic_sup_name(opts),
          %{
            id: {DataFetcher, :first_process, opts[:name]},
            start: mfa
          }
        ]
      }
    }
  end
end
