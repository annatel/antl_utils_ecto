defmodule Child do
  use Ecto.Schema

  schema "child" do
    field(:field1, :string)
    field(:field2, :string)

    belongs_to(:parent, Parent)
    belongs_to(:parent_with_include_with_metadata, ParentWithIncludeWithMetadata)
    belongs_to(:parent_with_queryable_overrided, ParentWithQueryableOverrided)
  end
end
