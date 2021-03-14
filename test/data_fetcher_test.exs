defmodule DataFetcherTest do
  use ExUnit.Case
  doctest DataFetcher

  test "greets the world" do
    assert DataFetcher.hello() == :world
  end
end
