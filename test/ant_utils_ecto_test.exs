defmodule AntlUtilsEctoTest do
  use ExUnit.Case, async: false
  use AntlUtilsEcto.DataCase
  doctest AntlUtilsEcto

  defmodule Schema do
    use Ecto.Schema

    schema "" do
      field(:name, :string)
      field(:wives, {:array, :string}, default: [])
      has_many(:children, Schema)
    end

    def changeset(%__MODULE__{} = schema, attrs) do
      schema
      |> Ecto.Changeset.cast(attrs, [:name, :wives])
      |> Ecto.Changeset.cast_assoc(:children)
    end
  end

  test "map_from_struct/1" do
    schema =
      %Schema{}
      |> Schema.changeset(%{
        name: "abraham",
        wives: ["sarah", "hagar"],
        children: [
          %{
            name: "isaac",
            children: [%{name: "esau"}, %{name: "jacob"}]
          }
        ]
      })
      |> Ecto.Changeset.apply_changes()

    terah = %{name: "terah", children: [schema]} |> AntlUtilsEcto.map_from_struct()

    refute Map.has_key?(terah, :__struct__)

    [abraham] = terah.children
    refute Map.has_key?(abraham, :__struct__)

    [isaac] = abraham.children
    refute Map.has_key?(isaac, :__struct__)

    [esau, jacob] = isaac.children
    refute Map.has_key?(esau, :__struct__)
    refute Map.has_key?(jacob, :__struct__)
  end
end
