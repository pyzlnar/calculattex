defmodule Calculattex.DSL do
  alias Calculattex.{Compiler, Runner, Step}

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [step: 3]
    end
  end

  defmacro step(name, desc \\ nil, do: block) when is_atom(name) do
    compiled_block = Compiler.compile_block(block)
    compiled_lines = Compiler.compile_lines(block)

    quote do
      def _fast_step(unquote(name), bindings) do
        Runner.eval_quoted(bindings, unquote(compiled_block))
      end

      def _full_step(unquote(name), bindings) do
        step = Step.build(unquote(name), unquote(desc), bindings)
        Runner.eval_lines(step, unquote(compiled_lines))
      end
    end
  end
end
