defmodule AntlUtilsEcto.QueryTest do
  use ExUnit.Case, async: false

  import Ecto.Query

  alias AntlUtilsEcto.Query, as: EctoQueryUtils

  defmodule SchemaWhere do
    use Ecto.Schema

    embedded_schema do
      field(:name, :string)
    end
  end

  describe "where/3" do
    test "where nil" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where(:name, nil)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: is_nil(q.name))

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where equal binary" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where(:name, "eliel")
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name == ^"eliel")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where equal integer" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where(:name, 1)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name == ^1)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where in" do
      %{wheres: [where_1]} =
        SchemaWhere |> EctoQueryUtils.where(:name, ["eliel", "laetitia", "jeremy"])

      %{wheres: [where_2]} =
        from(q in SchemaWhere, where: q.name in ^["eliel", "laetitia", "jeremy"])

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end
  end

  test "where_like/3" do
    %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where_like(:name, "foo")
    %{wheres: [where_2]} = from(q in SchemaWhere, where: like(q.name, ^"%foo%"))

    assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
  end

  describe "or_where/3" do
    test "or_where nil" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where(:name, nil)
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: is_nil(q.name))

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where equal" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where(:name, "eliel")
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name == ^"eliel")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where in" do
      %{wheres: [where_1]} =
        SchemaWhere |> EctoQueryUtils.or_where(:name, ["eliel", "laetitia", "jeremy"])

      %{wheres: [where_2]} =
        from(q in SchemaWhere, or_where: q.name in ^["eliel", "laetitia", "jeremy"])

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end
  end

  test "or_where_like/3" do
    %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where_like(:name, "foo")
    %{wheres: [where_2]} = from(q in SchemaWhere, or_where: like(q.name, ^"%foo%"))

    assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
  end

  test "order_by/3" do
    %{order_bys: [order_by_1]} = SchemaWhere |> EctoQueryUtils.order_by(:name, :asc)
    %{order_bys: [order_by_2]} = from(q in SchemaWhere, order_by: [asc: :name])

    assert Macro.to_string(order_by_1.expr) == Macro.to_string(order_by_2.expr)
  end
end
