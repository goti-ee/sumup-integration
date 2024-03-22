defmodule SumupIntegrationTest do
  use ExUnit.Case
  doctest SumupIntegration

  test "greets the world" do
    assert SumupIntegration.hello() == :world
  end
end
