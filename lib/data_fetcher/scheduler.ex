defmodule DataFetcher.Scheduler do
  @moduledoc false

  use Task, restart: :permanent

  @default_interval Application.compile_env(:data_fetcher, :default_interval, :timer.minutes(10))

  def start_link(opts) do
    interval = Keyword.get(opts, :interval, @default_interval)

    Task.start_link(fn ->
      loop(0, interval, opts)
    end)
  end

  defp loop(iteration, interval, opts) do
    spawn_worker(iteration, opts)
    :timer.sleep(interval)

    loop(iteration + 1, interval, opts)
  end

  defp spawn_worker(iteration, opts) do
    DataFetcher.WorkerSupervisor.spawn_worker(opts[:name], worker_spec(iteration, opts))
  end

  defp worker_spec(iteration, opts) do
    %{
      id: iteration,
      start: {DataFetcher.Worker, :start_link, [Keyword.put(opts, :iteration, iteration)]},
      restart: :transient
    }
  end
end
