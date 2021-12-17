defmodule Calculattex.Runner do
  alias Calculattex.Step

  def eval_quoted(bindings, ast) do
    ast
    |> Code.eval_quoted(bindings)
    |> elem(1)
  end

  def eval_substitution(bindings, ast) do
    ast
    |> Code.eval_quoted(bindings: bindings)
    |> elem(0)
  end

  def eval_lines(step, lines) do
    lines
    |> Enum.reduce(step, fn line, step ->
      line
      |> process_line(step.results)
      |> update_step(step)
    end)
    |> Step.reverse_lines
  end

  def process_line({name, formula, predicate_ast, line_ast}, bindings) do
    results = Calculattex.Runner.eval_quoted(bindings, line_ast)
    subs    = Calculattex.Runner.eval_substitution(bindings, predicate_ast)
    result  = Keyword.get(results, name)

    {
      {
        name,
        formula,
        subs,
        result,
      },
      results
    }
  end

  def update_step(update, step) do
    step |> Step.update(update)
  end
end
