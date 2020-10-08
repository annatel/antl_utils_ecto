defmodule AntlUtilsEcto do
  @spec map_from_struct(map) :: map
  def map_from_struct(%_{__meta__: %{__struct__: _}} = schema) when is_map(schema) do
    schema
    |> Map.from_struct()
    |> map_from_struct()
  end

  def map_from_struct(map) when is_map(map) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      value =
        case value do
          %_{__meta__: %{__struct__: _}} ->
            map_from_struct(value)

          value when is_list(value) ->
            value |> Enum.map(&map_from_struct/1)

          _ ->
            value
        end

      Map.put_new(acc, key, value)
    end)
  end
end
