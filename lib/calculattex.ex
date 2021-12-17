defmodule Calculattex do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [step: 3]
    end
  end

  # TODO: Remove logging
  defmacro step(name, desc \\ nil, do: block) when is_atom(name) do
    {:__block__, _, lines} = block
    lines = lines |> Enum.map(&compile_line/1) |> Macro.escape

    fast_version = compile_fast_version(block)
    result = quote do
      def _fast_step(unquote(name), bindings) do
        Calculattex.Runner.eval_quoted(bindings, unquote(fast_version))
      end

      def _full_step(unquote(name), bindings) do
        step = Calculattex.Step.build(unquote(name), unquote(desc), bindings)
        Calculattex.Runner.eval_lines(step, unquote(lines))
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

  def _compile_fast_version({op, _ctx, args}), do: {op, [], args}
  def _compile_fast_version(other),            do: other

  def _compile_substitution({var, _, nil}) when is_atom(var) do
    quote do
      inspect(Keyword.fetch!(var!(bindings), unquote(var)))
    end
  end

  def _compile_substitution({operator, _, [a1, a2]}) when operator in ~W[+ - / * **]a do
    quote do
      unquote(a1) <> unquote(" #{operator} ") <> unquote(a2)
    end
  end

  def _compile_substitution(number) when is_number(number), do: inspect(number)
  def _compile_substitution(other),                         do: other

  def compile_line({:=, _, [{name, _, _}, predicate]} = line) when is_atom(name) do
    {
      name,
      Macro.to_string(predicate),
      Macro.postwalk(predicate, &_compile_substitution/1),
      Macro.prewalk(line, &_compile_fast_version/1)
    }
  end

  def compile_line(other), do: :error
end
