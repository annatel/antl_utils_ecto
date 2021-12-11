defmodule AntlUtilsEcto do
  @doc """
  Recursive Schema to map function.
  """

  @spec map_from_struct(map) :: map
  def map_from_struct(schema) when is_struct(schema) do
    schema
    |> to_map()
  end

  defp to_map(schema) when is_struct(schema) do
    if not ecto_schema?(schema) do
      schema
    else
      schema
      |> Map.from_struct()
      |> Enum.map(fn {key, value} -> {key, to_map(value)} end)
      |> Enum.into(%{})
    end
  end

  defp to_map(value) do
    cond do
      is_map(value) -> to_map(value)
      is_list(value) -> Enum.map(value, &to_map/1)
      true -> value
    end
  end

  defp ecto_schema?(%{__meta__: %{__struct__: Ecto.Schema.Metadata}}), do: true

  defp ecto_schema?(schema) when is_struct(schema) do
    try do
      schema.__struct__.__schema__(:source)
    rescue
      UndefinedFunctionError -> false
    else
      _ -> true
    end
  end

  defp ecto_schema?(_), do: false
end
