defmodule DataFetcher.Registry do
  @moduledoc false

  def child_spec(name),
    do:
      Registry.child_spec(
        name: registry_name(name),
        keys: :unique
      )

  def registry_name(fetcher_name),
    do: Module.concat(__MODULE__, fetcher_name)
end
