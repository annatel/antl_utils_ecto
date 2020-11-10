defmodule AntlUtilsEcto.QueryableTest do
  use ExUnit.Case, async: false

  import Ecto.Query

  alias AntlUtilsEcto.Query, as: EctoQueryUtils

  describe "queryable" do
    test "queryable no overrided" do
      assert Parent == Parent.queryable()
    end

    test "queryable overrided" do
      assert inspect(from(p in ParentWithQueryableOverrided, left_join: c in assoc(p, :childs))) ==
               inspect(ParentWithQueryableOverrided.queryable())
    end
  end

  # describe "paginate" do
  # end

  describe "sort/2" do
    test "raises when field is not sortable" do
      assert_raise FunctionClauseError, fn ->
        Parent.queryable()
        |> Parent.sort(%{field: :to_operator, order: :asc})
      end
    end

    test "with no sort_params, sort by the first sortable_field desc" do
      %{order_bys: [order_by_1]} = Parent.queryable() |> Parent.sort()
      %{order_bys: [order_by_2]} = Parent.queryable() |> Parent.sort(%{})

      %{order_bys: [order_by_3]} =
        ParentWithSortableFields.queryable() |> ParentWithSortableFields.sort(%{})

      assert [desc: {{_, _, [_, :inserted_at]}, _, _}] = order_by_1.expr
      assert [desc: {{_, _, [_, :inserted_at]}, _, _}] = order_by_2.expr
      assert [desc: {{_, _, [_, :field1]}, _, _}] = order_by_3.expr
    end

    test "with a sort_params that is not an atom" do
      assert_raise FunctionClauseError, fn ->
        Parent.queryable() |> Parent.sort(%{field: "inserted_at", order: :asc})
      end
    end

    test "with a order_params that is not an atom" do
      assert_raise FunctionClauseError, fn ->
        Parent.queryable() |> Parent.sort(%{field: :inserted_at, order: "asc"})
      end
    end

    test "with a valid sort_params" do
      %{order_bys: [order_by]} = Parent.queryable() |> Parent.sort()
      Parent.queryable() |> Parent.sort(%{field: :inserted_at, order: :asc})

      assert [desc: {{_, _, [_, :inserted_at]}, _, _}] = order_by.expr
    end
  end

  describe "filter/2" do
    test "without override use the default filter" do
      %{wheres: [where_1]} = Parent.queryable() |> Parent.filter([field1: "123456"], [:field1])

      %{wheres: [where_2]} = from(p in Parent, where: p.field1 == ^"123456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_2.params)
    end

    test "ignore non listed filters" do
      assert Parent.queryable() |> Parent.filter(field1: "123456") == Parent.queryable()
    end

    test "default filters" do
      %{wheres: [where_1]} =
        ParentWithDefaultFilter.queryable() |> ParentWithDefaultFilter.filter(field1: "123456")

      %{wheres: [where_2]} = from(p in ParentWithDefaultFilter, where: p.field1 == ^"123456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_2.params)
    end

    test "with an override" do
      %{wheres: [where_1]} =
        ParentWithFilterOverrided.queryable()
        |> ParentWithFilterOverrided.filter([field1: "123456"], [:field1])

      %{wheres: [where_2]} =
        ParentWithFilterOverrided |> EctoQueryUtils.where_like(:field1, "123456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_2.params)
    end
  end

  describe "search/2" do
    test "when search_query is nil return the queryable" do
      search_query = nil

      query = Parent.queryable() |> Parent.search(search_query)

      assert Parent.queryable() == query
    end

    test "when search_query is an empty string return the queryable" do
      search_query = ""

      query = Parent.queryable() |> Parent.search(search_query)

      assert Parent.queryable() == query
    end

    test "ignore non searchable fields" do
      search_query = "toto"

      query_1 = Parent.queryable() |> Parent.search(search_query)

      query_2 = from(p in Parent, where: false or like(p.id, ^"%toto%"))

      assert inspect(query_1) == inspect(query_2)
    end

    test "search in all searchable fields" do
      search_query = "toto"

      query_1 =
        ParentWithSearchableFields.queryable() |> ParentWithSearchableFields.search(search_query)

      query_2 =
        from(p in ParentWithSearchableFields,
          where: false or like(p.field1, ^"%toto%") or like(p.field2, ^"%toto%")
        )

      assert inspect(query_1) == inspect(query_2)
    end

    test "search with an overrided search fields" do
      search_query = "toto"

      query_1 =
        ParentWithSearchOverrided.queryable() |> ParentWithSearchOverrided.search(search_query)

      query_2 = from(p in ParentWithSearchOverrided, where: false or p.field1 == ^"toto")

      assert inspect(query_1) == inspect(query_2)
    end

    test "search with an overrided search fields with metadata" do
      search_query = "toto"

      query_1 =
        ParentWithSearchWithMetadataOverrided.queryable()
        |> ParentWithSearchWithMetadataOverrided.search(search_query, field2: "tata")

      query_2 =
        from(p in ParentWithSearchWithMetadataOverrided,
          where: false or (p.field1 == ^"toto" and p.field2 == ^"tata")
        )

      assert inspect(query_1) == inspect(query_2)
    end

    test "search in a specific fields only" do
      search_query = "toto"

      query_1 =
        ParentWithSearchableFields.queryable()
        |> ParentWithSearchableFields.search(search_query, [], [:field1])

      query_2 = from(p in ParentWithSearchableFields, where: false or like(p.field1, ^"%toto%"))

      assert inspect(query_1) == inspect(query_2)
    end
  end
end
