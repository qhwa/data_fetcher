DataFetcher.Supervisor.start_link(
  name: :test_fetcher,
  fetcher: fn ->
    :timer.sleep(1000)

    if :rand.uniform() > 0.5 do
      :error
    else
      {:ok, :rand.uniform()}
    end
  end
)

DataFetcher.result(:test_fetcher) |> IO.inspect()
