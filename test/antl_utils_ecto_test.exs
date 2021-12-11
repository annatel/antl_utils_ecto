defmodule AntlUtilsEctoTest do
  use AntlUtilsEcto.DataCase
  doctest AntlUtilsEcto

  defmodule Schema do
    use Ecto.Schema

    schema "" do
      field(:name, :string)
      field(:wives, {:array, :string}, default: [])
      belongs_to(:parent, Schema)
      has_many(:children, Schema)
      field(:birthday, :utc_datetime, default: DateTime.utc_now())
      field(:rdvs, {:array, :utc_datetime}, default: [])
    end
  end

  defmodule EmbeddedSchema do
    use Ecto.Schema

    embedded_schema do
      field(:name, :string)
      field(:wives, {:array, :string}, default: [])
      embeds_one(:parent, EmbeddedSchema)
      embeds_many(:children, EmbeddedSchema)
      field(:birthday, :utc_datetime, default: DateTime.utc_now())
      field(:rdvs, {:array, :utc_datetime}, default: [])
    end
  end

  describe "map_from_struct/1" do
    test "for ecto schema" do
      abraham =
        %Schema{
          name: "abraham",
          wives: ["sarah", "hagar"],
          parent: %Schema{name: "terah"},
          birthday: DateTime.utc_now(),
          children: [
            %Schema{
              name: "isaac",
              children: [%Schema{name: "esau"}, %Schema{name: "jacob"}]
            }
          ],
          rdvs: [DateTime.utc_now(), DateTime.utc_now()]
        }
        |> AntlUtilsEcto.map_from_struct()

      refute Map.has_key?(abraham, :__struct__)
      assert %DateTime{} = abraham.birthday

      [isaac] = abraham.children
      refute Map.has_key?(isaac, :__struct__)

      [esau, jacob] = isaac.children
      refute Map.has_key?(esau, :__struct__)
      refute Map.has_key?(jacob, :__struct__)

      Enum.each(abraham.rdvs, &assert(%DateTime{} = &1))
    end

    test "for local ecto embedded_schema" do
      abraham =
        %EmbeddedSchema{
          name: "abraham",
          wives: ["sarah", "hagar"],
          parent: %EmbeddedSchema{name: "terah"},
          birthday: DateTime.utc_now(),
          children: [
            %EmbeddedSchema{
              name: "isaac",
              children: [%EmbeddedSchema{name: "esau"}, %EmbeddedSchema{name: "jacob"}]
            }
          ],
          rdvs: [DateTime.utc_now(), DateTime.utc_now()]
        }
        |> AntlUtilsEcto.map_from_struct()

      refute Map.has_key?(abraham, :__struct__)
      assert %DateTime{} = abraham.birthday

      [isaac] = abraham.children
      refute Map.has_key?(isaac, :__struct__)

      [esau, jacob] = isaac.children
      refute Map.has_key?(esau, :__struct__)
      refute Map.has_key?(jacob, :__struct__)

      Enum.each(abraham.rdvs, &assert(%DateTime{} = &1))
    end

    test "for remote ecto embedded_schema " do
      abraham =
        %{
          __meta__: %Ecto.Schema.Metadata{},
          __struct__: RemoteApp.Module.EmbeddedSchema,
          name: "abraham",
          wives: ["sarah", "hagar"],
          parent: %{
            __meta__: %Ecto.Schema.Metadata{},
            __struct__: RemoteApp.Module.EmbeddedSchema,
            name: "terah"
          },
          birthday: DateTime.utc_now(),
          children: [
            %{
              __meta__: %Ecto.Schema.Metadata{},
              __struct__: RemoteApp.Module.EmbeddedSchema,
              name: "isaac",
              children: [
                %{
                  __meta__: %Ecto.Schema.Metadata{},
                  __struct__: RemoteApp.Module.EmbeddedSchema,
                  name: "esau"
                },
                %{
                  __meta__: %Ecto.Schema.Metadata{},
                  __struct__: RemoteApp.Module.EmbeddedSchema,
                  name: "jacob"
                }
              ]
            }
          ],
          rdvs: [DateTime.utc_now(), DateTime.utc_now()]
        }
        |> AntlUtilsEcto.map_from_struct()

      refute Map.has_key?(abraham, :__struct__)
      assert %DateTime{} = abraham.birthday

      [isaac] = abraham.children
      refute Map.has_key?(isaac, :__struct__)

      [esau, jacob] = isaac.children
      refute Map.has_key?(esau, :__struct__)
      refute Map.has_key?(jacob, :__struct__)

      Enum.each(abraham.rdvs, &assert(%DateTime{} = &1))
    end
  end
end
