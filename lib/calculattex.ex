defmodule Calculattex do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [step: 3]
    end
  end

  # TODO: Remove logging
  defmacro step(name, _desc \\ nil, do: block) when is_atom(name) do
    IO.puts inspect(block)
    IO.puts "---"
    Macro.prewalk(block, fn {_, ctx, _} -> IO.puts(inspect(ctx))
      other -> other end)
    IO.puts ""

    fast_version = compile_fast_version(block)
    result = quote do
      def _fast_step(unquote(name), bindings) do
        unquote(fast_version)
        |> Code.eval_quoted(bindings)
        |> elem(1)
      end
    end

    IO.puts "--- Compiled ---"
    IO.puts Macro.to_string(result)
    result
  end

  def compile_fast_version(ast) do
    ast
    |> Macro.prewalk(&_compile_fast_version/1)
    |> Macro.escape
  end

  def _compile_fast_version({lhs, [if_undefined: :apply], rhs}) do
    {:var!, [], [{lhs, [], rhs}]}
  end

  # TODO: Remove logging
  def _compile_fast_version({lhs, _ctx, rhs}) do
    # if ctx != [], do: IO.puts inspect(ctx)
    {lhs, [], rhs}
  end

  def _compile_fast_version(other), do: other
end
