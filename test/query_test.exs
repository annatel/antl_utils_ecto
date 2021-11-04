defmodule AntlUtilsEcto.QueryTest do
  use ExUnit.Case, async: false

  import Ecto.Query

  alias AntlUtilsEcto.Query, as: EctoQueryUtils

  defmodule SchemaWhere do
    use Ecto.Schema

    embedded_schema do
      field(:name, :string)
      field(:start_at, :utc_datetime)
      field(:end_at, :utc_datetime)
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

    test "where equal boolean" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where(:name, true)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name == ^true)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)

      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where(:name, false)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name == ^false)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where in" do
      %{wheres: [where_1]} =
        SchemaWhere |> EctoQueryUtils.where(:name, ["eliel", "laetitia", "jeremy"])

      %{wheres: [where_2]} =
        from(q in SchemaWhere, where: q.name in ^["eliel", "laetitia", "jeremy"])

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where in []" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where(:name, [])

      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name in ^[])

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end
  end

  describe "where_not/3" do
    test "where not nil" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where_not(:name, nil)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: not is_nil(q.name))

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where not equal binary" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where_not(:name, "eliel")
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name != ^"eliel")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where not equal integer" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where_not(:name, 1)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name != ^1)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where not equal boolean" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where_not(:name, true)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name != ^true)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)

      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where_not(:name, false)
      %{wheres: [where_2]} = from(q in SchemaWhere, where: q.name != ^false)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "where not in" do
      %{wheres: [where_1]} =
        SchemaWhere |> EctoQueryUtils.where_not(:name, ["eliel", "laetitia", "jeremy"])

      %{wheres: [where_2]} =
        from(q in SchemaWhere, where: q.name not in ^["eliel", "laetitia", "jeremy"])

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end
  end

  test "where_like/3" do
    %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.where_like(:name, "foo")
    %{wheres: [where_2]} = from(q in SchemaWhere, where: like(q.name, ^"%foo%"))

    assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
  end

  describe "where_period_status/5" do
    test "ongoing" do
      datetime = DateTime.utc_now()

      %{wheres: [where_1]} =
        SchemaWhere |> EctoQueryUtils.where_period_status(:ongoing, :start_at, :end_at, datetime)

      %{wheres: [where_2]} =
        from(q in SchemaWhere,
          where: false or (q.start_at <= ^datetime and (q.end_at > ^datetime or is_nil(q.end_at)))
        )

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "ended" do
      datetime = DateTime.utc_now()

      %{wheres: [where_1]} =
        SchemaWhere |> EctoQueryUtils.where_period_status(:ended, :start_at, :end_at, datetime)

      %{wheres: [where_2]} =
        from(q in SchemaWhere, where: false or (q.start_at <= ^datetime and q.end_at <= ^datetime))

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "scheduled" do
      datetime = DateTime.utc_now()

      %{wheres: [where_1]} =
        SchemaWhere
        |> EctoQueryUtils.where_period_status(:scheduled, :start_at, :end_at, datetime)

      %{wheres: [where_2]} =
        from(q in SchemaWhere,
          where: false or (q.start_at > ^datetime and (q.end_at > ^datetime or is_nil(q.end_at)))
        )

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "multiple statuses" do
      datetime = DateTime.utc_now()

      %{wheres: [where_1]} =
        SchemaWhere
        |> EctoQueryUtils.where_period_status([:ended, :ongoing], :start_at, :end_at, datetime)

      %{wheres: [where_2]} =
        from(q in SchemaWhere,
          where:
            false or (q.start_at <= ^datetime and q.end_at <= ^datetime) or
              (q.start_at <= ^datetime and (q.end_at > ^datetime or is_nil(q.end_at)))
        )

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where in []" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where(:name, [])

      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name in ^[])

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end
  end

  describe "or_where/3" do
    test "or_where nil" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where(:name, nil)
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: is_nil(q.name))

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where equal binary" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where(:name, "eliel")
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name == ^"eliel")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where equal integer" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where(:name, 1)
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name == ^1)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where equal boolean" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where(:name, false)
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name == ^false)

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

  describe "or_where_not/3" do
    test "or_where_not nil" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where_not(:name, nil)
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: not is_nil(q.name))

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where_not equal binary" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where_not(:name, "eliel")
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name != ^"eliel")

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where_not equal integer" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where_not(:name, 1)
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name != ^1)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where_not equal boolean" do
      %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where_not(:name, false)
      %{wheres: [where_2]} = from(q in SchemaWhere, or_where: q.name != ^false)

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end

    test "or_where_not in" do
      %{wheres: [where_1]} =
        SchemaWhere |> EctoQueryUtils.or_where_not(:name, ["eliel", "laetitia", "jeremy"])

      %{wheres: [where_2]} =
        from(q in SchemaWhere, or_where: q.name not in ^["eliel", "laetitia", "jeremy"])

      assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
    end
  end

  test "or_where_like/3" do
    %{wheres: [where_1]} = SchemaWhere |> EctoQueryUtils.or_where_like(:name, "foo")
    %{wheres: [where_2]} = from(q in SchemaWhere, or_where: like(q.name, ^"%foo%"))

    assert Macro.to_string(where_1.expr) == Macro.to_string(where_2.expr)
  end
end
