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

  defmodule EmbeddedSchema do
    use Ecto.Schema

    embedded_schema do
      field(:name, :string)
      embeds_many(:children, EmbeddedSchema)
    end

    def changeset(%__MODULE__{} = schema, attrs) do
      schema
      |> Ecto.Changeset.cast(attrs, [:name])
      |> Ecto.Changeset.cast_embed(:children)
    end
  end

  describe "map_from_struct/1" do
    test "for ecto schema" do
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

      terah = %Schema{name: "terah", children: [schema]} |> AntlUtilsEcto.map_from_struct()

      refute Map.has_key?(terah, :__struct__)

      [abraham] = terah.children
      refute Map.has_key?(abraham, :__struct__)

      [isaac] = abraham.children
      refute Map.has_key?(isaac, :__struct__)

      [esau, jacob] = isaac.children
      refute Map.has_key?(esau, :__struct__)
      refute Map.has_key?(jacob, :__struct__)
    end

    test "for ecto embedded_schema" do
      schema =
        %EmbeddedSchema{}
        |> EmbeddedSchema.changeset(%{
          name: "abraham",
          children: [%{name: "isaac"}]
        })
        |> Ecto.Changeset.apply_changes()

      terah =
        %EmbeddedSchema{name: "terah", children: [schema]} |> AntlUtilsEcto.map_from_struct()

      refute Map.has_key?(terah, :__struct__)

      [abraham] = terah.children
      refute Map.has_key?(abraham, :__struct__)

      [isaac] = abraham.children
      refute Map.has_key?(isaac, :__struct__)
    end
  end
end
