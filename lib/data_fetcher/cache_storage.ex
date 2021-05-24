defmodule DataFetcher.CacheStorage do
  @moduledoc """
  Cache storage behaviour.
  """
  @callback init(keyword()) :: :ok | {:error, any()}
  @callback put(name :: atom(), result :: any()) :: :ok | {:error, any()}
  @callback get(name :: atom()) :: {:ok, result :: any()} | nil
end
