defmodule CalculattexTest do
  use ExUnit.Case, async: true

  alias Support.SimpleCalculator, as: Calculator
  alias Calculattex.Step

  describe "_fast_step/2" do
    test "does calculations and returns bindings" do
      inputs   = [a: 8, b: 2]
      expected = [a: 8, b: 2, c: 10, d: 1000]
      result   = Calculator._fast_step(:add, inputs) |> Enum.sort

      assert expected == result
    end
  end

  describe "_full_step/2" do
    test "does all the calculations and returns a step" do
      inputs   = [a: 8, b: 2]
      expected = [a: 8, b: 2, c: 10, d: 1000]
      result   = Calculator._full_step(:add, inputs)

      expected_lines = [
        {:c, "a + b",   "8 + 2",    10},
        {:d, "c * 100", "10 * 100", 1000}
      ]

      assert %Step{} = result
      assert result.name               == :add
      assert result.inputs             == inputs
      assert result.description        == "Applies the operations"
      assert Enum.sort(result.results) == expected
      assert result.lines              == expected_lines
    end
  end
end
