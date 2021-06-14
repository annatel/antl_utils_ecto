defmodule Parent do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  embedded_schema do
    field(:field1, :string)

    has_many(:childs, Child)
  end

  defp include_assoc(:childs, queryable) do
    queryable |> Ecto.Query.preload(:childs)
  end
end

defmodule ParentWithQueryableOverrided do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  import Ecto.Query

  embedded_schema do
    field(:field1, :string)

    has_many(:childs, Child)
  end

  def queryable() do
    __MODULE__
    |> join(:left, [p], childs in assoc(p, :childs))
  end
end

defmodule ParentWithFilterOverrided do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  embedded_schema do
    field(:field1, :string)
  end

  defp filter_by_field({:field1, value}, queryable) do
    queryable |> AntlUtilsEcto.Query.where_like(:field1, value)
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

  defp search_by_field({:field1, value}, dynamic) do
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

  defp search_by_field({:field1, value}, dynamic, field2: field2) do
    dynamic([q], ^dynamic or (q.field1 == ^value and q.field2 == ^field2))
  end
end
