fetchers = %{
  small_atom: fn -> {:ok, :foo} end,
  huge_list: fn -> {:ok, 1..1_000_000 |> Enum.to_list()} end
}

fetchers
|> Enum.flat_map(fn {name, fetcher} ->
  [
    {DataFetcher, name: :"#{name}_ets", fetcher: fetcher},
    {
      DataFetcher,
      name: :"#{name}_pt",
      fetcher: fetcher,
      cache_storage: DataFetcher.CacheStorage.PersistentTerm
    }
  ]
end)
|> Supervisor.start_link(strategy: :one_for_one)

Benchee.run(%{
  "small_atom_ets" => fn -> :foo = DataFetcher.result(:small_atom_ets) end,
  "small_atom_pt" => fn -> :foo = DataFetcher.result(:small_atom_pt) end,
  "huge_list_ets" => fn -> DataFetcher.result(:huge_list_ets) end,
  "huge_list_pt" => fn -> DataFetcher.result(:huge_list_pt) end
})
