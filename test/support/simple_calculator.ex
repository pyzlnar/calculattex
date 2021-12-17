defmodule Support.SimpleCalculator do
  use Calculattex

  # inputs [:a, :b]

  # calculate [
  #   "Add both variables",
  #   "divide result by 3"
  # ]

  step :add, "Applies the operations" do
    c = a + b
    d = c * 100
  end

  # step :divide, "divide result by 3" do
  #   @d = @c / 3
  # end
end
