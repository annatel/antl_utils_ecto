defmodule Parent do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  embedded_schema do
    field(:field1, :string)

    has_many(:children, Child)
    has_many(:children2, Child)
  end

  defp include_assoc(queryable, :children2) do
    queryable |> Ecto.Query.preload(:overriden)
  end
end

defmodule ParentWithIncludeWithMetadata do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  embedded_schema do
    field(:field1, :string)

    has_many(:children, Child)
    has_many(:children2, Child)
  end

  defp include_assoc(queryable, :children2, field1: value) do
    queryable |> Ecto.Query.preload(:overriden) |> AntlUtilsEcto.Query.where(:field1, value)
  end
end

defmodule ParentWithQueryableOverrided do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  import Ecto.Query

  embedded_schema do
    field(:field1, :string)

    has_many(:children, Child)
  end

  def queryable() do
    __MODULE__
    |> join(:left, [p], children in assoc(p, :children))
  end
end

defmodule ParentWithFilterOverrided do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  embedded_schema do
    field(:field1, :string)
  end

  defp filter_by_field(queryable, {:field1, value}) do
    queryable |> AntlUtilsEcto.Query.where_like(:field1, value)
  end

  defp filter_by_field(queryable, {:not, {:field1, value}}) do
    queryable |> AntlUtilsEcto.Query.where_like(:field1, value)
  end
end

defmodule ParentWithFilterOverridedWithMetadata do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  embedded_schema do
    field(:field1, :string)
    field(:field2, :string)
  end

  defp filter_by_field(queryable, {:field1, field1}, field2: field2) do
    queryable
    |> where(field1: ^field1, field2: ^field2)
  end

  defp filter_by_field(queryable, {:not, {:field1, field1}}, field2: field2) do
    queryable
    |> AntlUtilsEcto.Query.where_not(:field1, field1)
    |> where(field2: ^field2)
  end
end

defmodule ParentWithSearchableFields do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable, searchable_fields: [:field1, :field2]

  embedded_schema do
    field(:field1, :string)
  end
end

defmodule ParentWithSortableFields do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable, sortable_fields: [:field1, :field2]

  embedded_schema do
    field(:field1, :string)
  end
end

defmodule ParentWithSearchOverrided do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable, searchable_fields: [:field1]

  import Ecto.Query, only: [dynamic: 2]

  embedded_schema do
    field(:field1, :string)
  end

  defp search_by_field(dynamic, {:field1, value}) do
    dynamic([q], ^dynamic or q.field1 == ^value)
  end
end

defmodule ParentWithSearchWithMetadataOverrided do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable, searchable_fields: [:field1]

  import Ecto.Query, only: [dynamic: 2]

  embedded_schema do
    field(:field1, :string)
    field(:field2, :string)
  end

  defp search_by_field(dynamic, {:field1, value}, field2: field2) do
    dynamic([q], ^dynamic or (q.field1 == ^value and q.field2 == ^field2))
  end
end
