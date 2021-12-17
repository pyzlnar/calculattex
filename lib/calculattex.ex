defmodule Calculattex do
  defmacro __using__(_) do
    quote do
      use Calculattex.DSL
    end
  end
end
