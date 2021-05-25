defmodule MyFetcher do
  def fetch do
    {:ok, "Hello!"}
  end

  def fetch(term) do
    {:ok, term}
  end
end

defmodule DataFetcherTest do
  use ExUnit.Case
  doctest DataFetcher

  describe "get result while first fetch" do
    test "it waits for fetching to complete" do
      start_fetcher(
        name: :foo,
        fetcher: fn ->
          :timer.sleep(50)
          {:ok, BAR}
        end
      )

      assert DataFetcher.result(:foo) == BAR

      :timer.sleep(100)
      assert DataFetcher.result(:foo) == BAR
    end
  end

  describe "fetch periodicly" do
    setup do
      {:ok, pid} = Agent.start_link(fn -> 0 end)
      [agent: pid]
    end

    test "it works", %{agent: agent} do
      start_fetcher(
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
      )

      :timer.sleep(1050)
      assert DataFetcher.result(:advance) == 10
    end
  end

  describe "defining fetcher" do
    test "it works with anonymous function" do
      start_fetcher(
        name: :function_fetcher,
        fetcher: fn -> {:ok, %{foo: 1}} end
      )

      assert DataFetcher.result(:function_fetcher) == %{foo: 1}
    end

    test "it works with MFA" do
      start_fetcher(
        name: :mfa_fetcher,
        fetcher: {MyFetcher, :fetch, [:test]}
      )

      assert DataFetcher.result(:mfa_fetcher) == :test
    end

    test "it works with single module" do
      start_fetcher(
        name: :m_fetcher,
        fetcher: MyFetcher
      )

      assert DataFetcher.result(:m_fetcher) == "Hello!"
    end
  end

  defp start_fetcher(opts),
    do: {:ok, _} = Supervisor.start_link([{DataFetcher, opts}], strategy: :one_for_one)
end
