defmodule ExtrTest do
  use ExUnit.Case
  doctest Extr

  test "greets the world" do
    assert Extr.hello() == :world
  end
end
