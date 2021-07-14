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
    associations =
      try do
        schema.__struct__.__schema__(:associations)
      rescue
        UndefinedFunctionError -> []
      end

    embeds =
      try do
        schema.__struct__.__schema__(:embeds)
      rescue
        UndefinedFunctionError -> []
      end

    schema
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> Enum.map(fn {key, value} ->
      if key in (associations ++ embeds), do: {key, to_map(value)}, else: {key, value}
    end)
    |> Enum.into(%{})
  end

  defp to_map(map) when is_map(map) do
    Enum.map(map, fn {key, value} -> {key, to_map(value)} end)
    |> Enum.into(%{})
  end

  defp to_map(list) when is_list(list) do
    Enum.map(list, &to_map/1)
  end

  defp to_map(value), do: value
end
