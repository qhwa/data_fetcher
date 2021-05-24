defmodule DataFetcherTest do
  use ExUnit.Case
  doctest DataFetcher

  describe "get result while first fetch" do
    test "it waits for fetching to complete" do
      opts = [
        name: :foo,
        fetcher: fn -> {:ok, BAR} end
      ]

      {:ok, _} = DataFetcher.Supervisor.start_link(opts)

      assert DataFetcher.result(:foo) == BAR
    end
  end

  describe "fetch periodicly" do
    setup do
      {:ok, pid} = Agent.start_link(fn -> 0 end)
      [agent: pid]
    end

    test "it works", %{agent: agent} do
      opts = [
        name: :advance,
        fetcher: fn ->
          Agent.get_and_update(agent, fn x ->
            {
              {:ok, x},
              x + 1
            }
          end)
        end,
        interval: 100,
        cache_storage: DataFetcher.CacheStorage.PersistentTerm
      ]

      {:ok, _} = DataFetcher.Supervisor.start_link(opts)

      :timer.sleep(1050)
      assert DataFetcher.result(:advance) == 10
    end
  end
end
