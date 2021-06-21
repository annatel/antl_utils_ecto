defmodule AntlUtilsEcto.TestSchema do
  use Ecto.Schema
  use AntlUtilsEcto.Queryable

  schema "test_schemas" do
    field(:field1, :string)
    field(:field2, :string)
  end
end

defmodule AntlUtilsEcto.TestFactory do
  use AntlUtilsEcto.Factory, repo: AntlUtilsEcto.TestRepo

  def build(:test_schema, attrs) do
    %AntlUtilsEcto.TestSchema{field1: "a", field2: "b"} |> struct!(attrs)
  end
end
