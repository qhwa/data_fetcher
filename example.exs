DataFetcher.Supervisor.start_link(
  name: :test_fetcher,
  fetcher: fn _last_result ->
    :timer.sleep(1000)

    if :rand.uniform() > 0.5 do
      raise "fetching failed"
    else
      :rand.uniform()
    end
  end
)

DataFetcher.result(:test_fetcher) |> IO.inspect()
