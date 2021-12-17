defmodule CalculattexTest do
  use ExUnit.Case

  alias Support.SimpleCalculator, as: Calculator

  describe "_fast_step/2" do
    test "does calculations and returns bindings" do
      inputs   = [a: 8, b: 2]
      expected = [{:c, 10}, {:d, 1000} | inputs] |> Enum.sort
      result   = Calculator._fast_step(:add, inputs) |> Enum.sort

      assert expected == result
    end
  end
end
