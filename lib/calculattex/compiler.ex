defmodule Calculattex.Compiler do
  def compile_block(block) do
    block
    |> Macro.prewalk(&compile_with_bindable_vars/1)
    |> Macro.escape
  end

  def compile_lines({:__block__, _, lines}) do
    lines
    |> Enum.map(&compile_line/1)
    |> Macro.escape
  end

  def compile_with_bindable_vars({lhs, [if_undefined: :apply], rhs}) do
    {:var!, [], [{lhs, [], rhs}]}
  end

  def compile_with_bindable_vars({op, _ctx, args}), do: {op, [], args}
  def compile_with_bindable_vars(other),            do: other

  def compile_line({:=, _, [{name, _, _}, predicate]} = line) when is_atom(name) do
    {
      name,
      Macro.to_string(predicate),
      Macro.postwalk(predicate, &compile_for_substitution/1),
      Macro.prewalk(line, &compile_with_bindable_vars/1)
    }
  end

  def compile_line(_other), do: :error

  def compile_for_substitution({var, _, nil}) when is_atom(var) do
    quote do
      inspect(Keyword.fetch!(var!(bindings), unquote(var)))
    end
  end

  def compile_for_substitution({operator, _, [a1, a2]}) when operator in ~W[+ - / * **]a do
    quote do
      unquote(a1) <> unquote(" #{operator} ") <> unquote(a2)
    end
  end

  def compile_for_substitution(number) when is_number(number), do: inspect(number)
  def compile_for_substitution(other),                         do: other
end
