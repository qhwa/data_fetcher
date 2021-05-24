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
end
