defmodule Calculattex.Step do
  defstruct ~W[name description lines inputs results]a

  def build(name, description, inputs) do
    description = description || Atom.to_string(name)
    %__MODULE__{
      name:        name,
      description: description,
      lines:       [],
      inputs:      inputs,
      results:     inputs
    }
  end


  def update(%__MODULE__{} = step, {line, results}) do
    %{step|lines: [line|step.lines], results: results}
  end

  def reverse_lines(%__MODULE__{} = step) do
    %{step|lines: Enum.reverse(step.lines)}
  end
end
