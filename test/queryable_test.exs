defmodule AntlUtilsEcto.QueryableTest do
  use ExUnit.Case, async: false

  import Ecto.Query

  alias AntlUtilsEcto.Query, as: EctoQueryUtils

  describe "queryable" do
    test "queryable no overrided" do
      assert Parent == Parent.queryable()
    end

    test "queryable overrided" do
      assert inspect(from(p in ParentWithQueryableOverrided, left_join: c in assoc(p, :children))) ==
               inspect(ParentWithQueryableOverrided.queryable())
    end
  end

  test "searchable_fields/0" do
    assert ParentWithSearchableFields.searchable_fields() == [:field1, :field2]
  end

  describe "filter/2" do
    test "without override use the default filter" do
      %{wheres: [where_1]} = Parent.queryable() |> Parent.filter(%{field1: "123456"})

      %{wheres: [where_2]} = from(p in Parent, where: p.field1 == ^"123456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_2.params)
    end

    test "with an override" do
      %{wheres: [where_1]} =
        ParentWithFilterOverrided.queryable()
        |> ParentWithFilterOverrided.filter(%{field1: "123456"})

      %{wheres: [where_2]} =
        ParentWithFilterOverrided |> EctoQueryUtils.where_like(:field1, "123456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_2.params)
    end

    test "with an override with metadata" do
      query_1 =
        ParentWithFilterOverridedWithMetadata.queryable()
        |> ParentWithFilterOverridedWithMetadata.filter(%{field1: "123"}, field2: "456")

      query_2 =
        from(p in ParentWithFilterOverridedWithMetadata,
          where: p.field1 == ^"123" and p.field2 == ^"456"
        )

      assert inspect(query_1) == inspect(query_2)
    end

    test "list of filters and not filters" do
      %{wheres: [where_1, where_2]} =
        Parent.queryable() |> Parent.filter([{:not, {:field1, "123"}}, {:field2, "456"}])

      %{wheres: [where_3, where_4]} =
        from(p in Parent, where: p.field1 != ^"123", where: p.field2 == ^"456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_3.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_3.params)
      assert Macro.to_string(where_2.expr) == Macro.to_string(where_4.expr)
      assert Macro.to_string(where_2.params) == Macro.to_string(where_4.params)
    end

    test "not filter - without override use the default filter" do
      %{wheres: [where_1]} = Parent.queryable() |> Parent.filter(%{not: {:field1, "123456"}})

      %{wheres: [where_2]} = from(p in Parent, where: p.field1 != ^"123456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_2.params)
    end

    test "not filter - with an override" do
      %{wheres: [where_1]} =
        ParentWithFilterOverrided.queryable()
        |> ParentWithFilterOverrided.filter(%{not: {:field1, "123456"}})

      %{wheres: [where_2]} =
        ParentWithFilterOverrided |> EctoQueryUtils.where_like(:field1, "123456")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
      assert Macro.to_string(where_1.params) == Macro.to_string(where_2.params)
    end

    test "not filter - with an override with metadata" do
      query_1 =
        ParentWithFilterOverridedWithMetadata.queryable()
        |> ParentWithFilterOverridedWithMetadata.filter(%{not: {:field1, "123"}}, field2: "456")

      query_2 =
        from(p in ParentWithFilterOverridedWithMetadata,
          where: p.field1 != ^"123",
          where: p.field2 == ^"456"
        )

      assert inspect(query_1) == inspect(query_2)
    end
  end

  describe "include/2" do
    test "when include_assoc is not overriden, call the default include_assoc" do
      query = Parent.queryable() |> Parent.include([:children])
      assert inspect(query) == "#Ecto.Query<from p0 in Parent, preload: [:children]>"
    end

    test "when include_assoc is overriden, call the overriden include_assoc" do
      query = Parent.queryable() |> Parent.include([:children2])
      assert inspect(query) == "#Ecto.Query<from p0 in Parent, preload: [:overriden]>"
    end
  end

  describe "include/3" do
    test "when include_assoc is not overriden, call the default include_assoc" do
      query = Parent.queryable() |> Parent.include([:children], field1: "value")
      assert inspect(query) == "#Ecto.Query<from p0 in Parent, preload: [:children]>"
    end

    test "when include_assoc is overriden, call the overriden include_assoc" do
      query =
        Parent.queryable() |> ParentWithIncludeWithMetadata.include([:children2], field1: "value")

      assert inspect(query) ==
               "#Ecto.Query<from p0 in Parent, where: p0.field1 == ^\"value\", preload: [:overriden]>"
    end
  end

  describe "order_by/2" do
    test "when the order_by fields are empty, do not order_by" do
      query = Parent.queryable() |> Parent.order_by([])
      assert inspect(query) == "Parent"
    end

    test "support list of atoms" do
      query = Parent.queryable() |> Parent.order_by([:field1])
      assert inspect(query) == "#Ecto.Query<from p0 in Parent, order_by: [asc: p0.field1]>"
    end

    test "support keyword" do
      query = Parent.queryable() |> Parent.order_by(desc: :field1)
      assert inspect(query) == "#Ecto.Query<from p0 in Parent, order_by: [desc: p0.field1]>"
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

      query_2 =
        from(p in Parent,
          where: false or like(type(fragment("?", field(p, :id)), :string), ^"%toto%")
        )

      assert inspect(query_1) == inspect(query_2)
    end

    test "search in all searchable fields" do
      search_query = "toto"

      query_1 =
        ParentWithSearchableFields.queryable() |> ParentWithSearchableFields.search(search_query)

      query_2 =
        from(p in ParentWithSearchableFields,
          where:
            false or like(type(fragment("?", field(p, :field1)), :string), ^"%toto%") or
              like(type(fragment("?", field(p, :field2)), :string), ^"%toto%")
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

      query_2 =
        from(p in ParentWithSearchableFields,
          where: false or like(type(fragment("?", field(p, :field1)), :string), ^"%toto%")
        )

      assert inspect(query_1) == inspect(query_2)
    end
  end

  describe "select_fields/2" do
    test "when fields are list of atoms" do
      query = Parent.queryable() |> Parent.select_fields([:field1])
      assert inspect(query) == "#Ecto.Query<from p0 in Parent, select: [:field1]>"
    end

    test "when fields is an empty list, select all fields" do
      query = Parent.queryable() |> Parent.select_fields([])
      assert inspect(query) == "Parent"
    end

    test "when fields nil, select all fields" do
      query = Parent.queryable() |> Parent.select_fields(nil)
      assert inspect(query) == "Parent"
    end
  end
end
