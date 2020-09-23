defmodule AntlUtilsEcto.ChangesetTest do
  use ExUnit.Case, async: false
  use AntlUtilsEcto.DataCase
  doctest AntlUtilsEcto.Changeset

  import AntlUtilsEcto.Changeset

  @datetime1 DateTime.from_naive!(~N[2018-01-01 00:00:00], "Etc/UTC")
  @datetime2 DateTime.from_naive!(~N[2018-01-02 00:00:00], "Etc/UTC")
  @datetime3 DateTime.from_naive!(~N[2018-01-03 00:00:00], "Etc/UTC")

  defmodule Schema do
    use Ecto.Schema

    embedded_schema do
      field(:field_1, :string)
      field(:field_2, :string)
      field(:field_3, :string)
    end
  end

  defmodule DatetimesSchema do
    use Ecto.Schema

    embedded_schema do
      field(:datetime_1, :utc_datetime)
      field(:datetime_2, :utc_datetime)
    end
  end

  defmodule PeriodSchema do
    use Ecto.Schema

    embedded_schema do
      field(:start_at, :utc_datetime)
      field(:end_at, :utc_datetime)
    end
  end

  describe "validate_required_one_exclusive/2" do
    test "when only one is set" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_one_exclusive([:field_1, :field_2, :field_3])

      assert changeset.valid?
    end

    test "when no one is set" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_one_exclusive(
          [:field_1, :field_2, :field_3],
          key: "fields"
        )

      refute changeset.valid?

      assert %{fields: ["one of [:field_1, :field_2, :field_3] must be present"]} =
               errors_on(changeset)
    end

    test "when more than one is set" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_one_exclusive(
          [:field_1, :field_2, :field_3],
          key: :fields
        )

      refute changeset.valid?

      assert %{fields: ["only one of [:field_1, :field_2, :field_3] must be present"]} =
               errors_on(changeset)
    end
  end

  describe "validate_required_any/3" do
    test "when just min value is set" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any([:field_1, :field_2, :field_3],
          key: "fields",
          min: 2
        )

      assert changeset.valid?
    end

    test "when more of min value is set" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any([:field_1, :field_2, :field_3],
          key: "fields"
        )

      assert changeset.valid?
    end

    test "when no fields is set" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any([:field_1, :field_2, :field_3],
          key: "fields"
        )

      refute changeset.valid?

      assert %{fields: ["at least 1 of [:field_1, :field_2, :field_3] can't be blank"]} =
               errors_on(changeset)
    end
  end

  describe "validate_required_if/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_if([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_if([:field_3], :field_1, "field_1")

      refute changeset.valid?
      assert %{field_3: ["can't be blank when field_1 is field_1"]} = errors_on(changeset)
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_if([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_if([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end
  end

  describe "validate_required_unless/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_unless([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_unless([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_unless([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_unless([:field_3], :field_1, "field_1")

      refute changeset.valid?
      assert %{field_3: ["can't be blank unless field_1 is field_1"]} = errors_on(changeset)
    end
  end

  describe "validate_required_any_if/4" do
    test "the condition match and the minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_if(
          [:field_2, :field_3],
          :field_1,
          "field_1",
          key: "fields",
          min: 1
        )

      assert changeset.valid?
    end

    test "the condition match and less of minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_if(
          [:field_2, :field_3],
          :field_1,
          "field_1",
          key: "fields",
          min: 1
        )

      refute changeset.valid?

      assert %{
               fields: [
                 "at least 1 of [:field_2, :field_3] can't be blank when field_1 is field_1"
               ]
             } = errors_on(changeset)
    end

    test "the condition does not match and the minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_if(
          [:field_2, :field_3],
          :field_1,
          "field_1"
        )

      assert changeset.valid?
    end

    test "the condition does not match and less of minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_if(
          [:field_2, :field_3],
          :field_1,
          "field_1"
        )

      assert changeset.valid?
    end
  end

  describe "validate_required_any_unless/4" do
    test "the condition match and the minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_unless(
          [:field_2, :field_3],
          :field_1,
          "field_1"
        )

      assert changeset.valid?
    end

    test "the condition match and less of minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_unless(
          [:field_2, :field_3],
          :field_1,
          "field_1"
        )

      assert changeset.valid?
    end

    test "the condition does not match and the minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_unless(
          [:field_2, :field_3],
          :field_1,
          "field_1"
        )

      assert changeset.valid?
    end

    test "the condition does not match and less of minimum number of fields are present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_any_unless(
          [:field_2, :field_3],
          :field_1,
          "field_1",
          key: "fields"
        )

      refute changeset.valid?

      assert %{
               fields: [
                 "at least 1 of [:field_2, :field_3] can't be blank unless field_1 is field_1"
               ]
             } = errors_on(changeset)
    end
  end

  describe "validate_required_with/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, :field_3)

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1
      assert %{field_1: ["can't be blank when field_3 is present"]} = errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be blank when any of [:field_2, :field_3] are present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2

      assert %{field_1: ["can't be blank when any of [:field_3] are present"]} =
               errors_on(changeset)

      assert %{field_2: ["can't be blank when any of [:field_3] are present"]} =
               errors_on(changeset)
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_required_with_all/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be blank when field_2 and field_3 are present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2
      assert %{field_1: ["can't be blank when field_3 are present"]} = errors_on(changeset)
      assert %{field_2: ["can't be blank when field_3 are present"]} = errors_on(changeset)
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_with_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_required_without/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(%{field_1: "field_1"}, [:field_1, :field_2, :field_3])
        |> validate_required_without(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(%{field_1: "field_1"}, [:field_1, :field_2, :field_3])
        |> validate_required_without(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without(:field_1, :field_3)

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be blank when field_3 is not present"]} = errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be blank when any of [:field_2, :field_3] is not present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2

      assert %{field_1: ["can't be blank when any of [:field_3] is not present"]} =
               errors_on(changeset)

      assert %{field_2: ["can't be blank when any of [:field_3] is not present"]} =
               errors_on(changeset)
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_required_without_all/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be blank when field_2 and field_3 are not present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2
      assert %{field_1: ["can't be blank when field_3 are not present"]} = errors_on(changeset)
      assert %{field_2: ["can't be blank when field_3 are not present"]} = errors_on(changeset)
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_required_without_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_empty/3" do
    test "when the field does not exist in the changeset" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty([:field_1])

      assert changeset.valid?
    end

    test "when the field is set to nil" do
      changeset =
        %Schema{}
        |> change(%{field_3: nil})
        |> validate_empty([:field_1])

      assert changeset.valid?
    end

    test "when the field is not changed" do
      changeset =
        %Schema{field_3: "field_3"}
        |> change(%{field_3: "field_3"})
        |> validate_empty([:field_3])

      assert changeset.valid?
    end

    test "when the field is set to an empty string" do
      changeset =
        %Schema{}
        |> change(%{field_1: ""})
        |> validate_empty([:field_1])

      refute changeset.valid?
      assert %{field_1: ["can't be set"]} = errors_on(changeset)
    end

    test "when the field has a value" do
      changeset =
        %Schema{}
        |> change(%{field_1: "field_1"})
        |> validate_empty([:field_1])

      refute changeset.valid?
      assert %{field_1: ["can't be set"]} = errors_on(changeset)
    end

    test "when one of the fields has a value" do
      changeset =
        %Schema{}
        |> change(%{field_1: "field_1"})
        |> validate_empty([:field_1, :field_2])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1
      assert %{field_1: ["can't be set"]} = errors_on(changeset)
    end

    test "when all fields have a value" do
      changeset =
        %Schema{}
        |> change(%{field_1: "field_1", field_2: "field_2"})
        |> validate_empty([:field_1, :field_2])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2
      assert %{field_1: ["can't be set"]} = errors_on(changeset)
      assert %{field_2: ["can't be set"]} = errors_on(changeset)
    end
  end

  describe "validate_empty_if/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_if([:field_3], :field_1, "field_1")

      refute changeset.valid?
      assert %{field_3: ["can't be set when field_1 is field_1"]} = errors_on(changeset)
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_if([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_if([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_if([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end
  end

  describe "validate_empty_unless/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_unless([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_unless([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_unless([:field_3], :field_1, "field_1")

      refute changeset.valid?
      assert %{field_3: ["can't be set unless field_1 is field_1"]} = errors_on(changeset)
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "value"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_unless([:field_3], :field_1, "field_1")

      assert changeset.valid?
    end
  end

  describe "validate_empty_with/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, :field_3)

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1
      assert %{field_1: ["can't be set when field_3 is present"]} = errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be set when any of [:field_2, :field_3] are present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2

      assert %{field_1: ["can't be set when any of [:field_3] are present"]} =
               errors_on(changeset)

      assert %{field_2: ["can't be set when any of [:field_3] are present"]} =
               errors_on(changeset)
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_empty_with_all/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be blank when field_2 and field_3 are present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2
      assert %{field_1: ["can't be blank when field_3 are present"]} = errors_on(changeset)
      assert %{field_2: ["can't be blank when field_3 are present"]} = errors_on(changeset)
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_with_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_empty_without/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, :field_3)

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be set when field_3 is not present"]} = errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be set when any of [:field_2, :field_3] is not present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2

      assert %{field_1: ["can't be set when any of [:field_3] is not present"]} =
               errors_on(changeset)

      assert %{field_2: ["can't be set when any of [:field_3] is not present"]} =
               errors_on(changeset)
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, :field_3)

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_empty_without_all/4" do
    test "the condition match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all(:field_1, [:field_2, :field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 1

      assert %{field_1: ["can't be set when field_2 and field_3 are not present"]} =
               errors_on(changeset)

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all([:field_1, :field_2], [:field_3])

      refute changeset.valid?
      assert length(Map.keys(errors_on(changeset))) == 2
      assert %{field_1: ["can't be set when field_3 are not present"]} = errors_on(changeset)
      assert %{field_2: ["can't be set when field_3 are not present"]} = errors_on(changeset)
    end

    test "the condition match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_1: "field_1", field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end

    test "the condition does not match and the field is not present" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2", field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_2: "field_2"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all(:field_1, [:field_2, :field_3])

      assert changeset.valid?

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(
          %{field_3: "field_3"},
          [:field_1, :field_2, :field_3]
        )
        |> validate_empty_without_all([:field_1, :field_2], [:field_3])

      assert changeset.valid?
    end
  end

  describe "validate_datetime_lt/4" do
    test "when the first key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_lt(:key, :datetime_1)
      end
    end

    test "when the second key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_lt(:datetime_2, :key)
      end
    end

    test "when dates are equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lt(:datetime_1, :datetime_2)

      refute changeset.valid?
      assert %{datetime_1: ["should be before datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is after the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime2, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lt(:datetime_1, :datetime_2)

      refute changeset.valid?
      assert %{datetime_1: ["should be before datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is not set and the second one's value is set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lt(:datetime_1, :datetime_2)

      refute changeset.valid?
      assert %{datetime_1: ["should be before datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is before the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime2},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lt(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the keys' values are not set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lt(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the first key's value is set and the second key's one is not" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lt(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the second param is a datetime value - after" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime2}, [:datetime_1])
        |> validate_datetime_lt(:datetime_1, @datetime1)

      refute changeset.valid?
      assert %{datetime_1: ["should be before #{@datetime1}"]} == errors_on(changeset)
    end

    test "when the second param is a datetime value - equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_lt(:datetime_1, @datetime1)

      refute changeset.valid?
      assert %{datetime_1: ["should be before #{@datetime1}"]} == errors_on(changeset)
    end

    test "when the second param is a datetime value - before" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_lt(:datetime_1, @datetime2)

      assert changeset.valid?
    end
  end

  describe "validate_datetime_lte/4" do
    test "when the first key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_lte(:key, :datetime_1)
      end
    end

    test "when the second key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_lte(:datetime_2, :key)
      end
    end

    test "when the first key's value is after the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime2, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lte(:datetime_1, :datetime_2)

      refute changeset.valid?

      assert %{datetime_1: ["should be before or equal to datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is not set and the second one's value is set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lte(:datetime_1, :datetime_2)

      refute changeset.valid?

      assert %{datetime_1: ["should be before or equal to datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is before the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime2},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when dates are equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the keys' values are not set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the first key's value is set and the second key's one is not" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_lte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the second param is a datetime value - after" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime2}, [:datetime_1])
        |> validate_datetime_lte(:datetime_1, @datetime1)

      refute changeset.valid?

      assert %{datetime_1: ["should be before or equal to #{@datetime1}"]} ==
               errors_on(changeset)
    end

    test "when the second param is a datetime value - equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_lte(:datetime_1, @datetime1)

      assert changeset.valid?
    end

    test "when the second param is a datetime value - before" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_lte(:datetime_1, @datetime2)

      assert changeset.valid?
    end
  end

  describe "validate_datetime_gt/4" do
    test "when the first key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_gt(:key, :datetime_1)
      end
    end

    test "when the second key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_gt(:datetime_2, :key)
      end
    end

    test "when dates are equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gt(:datetime_1, :datetime_2)

      refute changeset.valid?
      assert %{datetime_1: ["should be after datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is set and the second key's one is not" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gt(:datetime_1, :datetime_2)

      refute changeset.valid?
      assert %{datetime_1: ["should be after datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is before the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime2},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gt(:datetime_1, :datetime_2)

      refute changeset.valid?
      assert %{datetime_1: ["should be after datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is after the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime2, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gt(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the keys' values are not set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gt(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the first key's value is not set and the second one's value is set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gt(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the second param is a datetime value - before" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_gt(:datetime_1, @datetime2)

      refute changeset.valid?
      assert %{datetime_1: ["should be after #{@datetime2}"]} == errors_on(changeset)
    end

    test "when the second param is a datetime value - equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_gt(:datetime_1, @datetime1)

      refute changeset.valid?
      assert %{datetime_1: ["should be after #{@datetime1}"]} == errors_on(changeset)
    end

    test "when the second param is a datetime value - after" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime2}, [:datetime_1])
        |> validate_datetime_gt(:datetime_1, @datetime1)

      assert changeset.valid?
    end
  end

  describe "validate_datetime_gte/4" do
    test "when the first key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_gte(:key, :datetime_1)
      end
    end

    test "when the second key is not in the changeset, raise a MatchError" do
      assert_raise MatchError, fn ->
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1, datetime_2: @datetime1}, [
          :datetime_1,
          :datetime_2
        ])
        |> validate_datetime_gte(:datetime_2, :key)
      end
    end

    test "when the first key's value is set and the second key's one is not" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gte(:datetime_1, :datetime_2)

      refute changeset.valid?

      assert %{datetime_1: ["should be after or equal to datetime_2"]} = errors_on(changeset)
    end

    test "when the first key's value is before the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime2},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gte(:datetime_1, :datetime_2)

      refute changeset.valid?

      assert %{datetime_1: ["should be after or equal to datetime_2"]} = errors_on(changeset)
    end

    test "when dates are equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime1, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the first key's value is after the second key's one" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: @datetime2, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the keys' values are not set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: nil},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the first key's value is not set and the second one's value is set" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(
          %{datetime_1: nil, datetime_2: @datetime1},
          [:datetime_1, :datetime_2]
        )
        |> validate_datetime_gte(:datetime_1, :datetime_2)

      assert changeset.valid?
    end

    test "when the second param is a datetime value - before" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_gte(:datetime_1, @datetime2)

      refute changeset.valid?

      assert %{datetime_1: ["should be after or equal to #{@datetime2}"]} ==
               errors_on(changeset)
    end

    test "when the second param is a datetime value - equal" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime1}, [:datetime_1])
        |> validate_datetime_gte(:datetime_1, @datetime1)

      assert changeset.valid?
    end

    test "when the second param is a datetime value - after" do
      changeset =
        %DatetimesSchema{}
        |> Ecto.Changeset.cast(%{datetime_1: @datetime2}, [:datetime_1])
        |> validate_datetime_gte(:datetime_1, @datetime1)

      assert changeset.valid?
    end
  end

  describe "validate_datetime_inclusion/4" do
    test "included start_at is nil, raises a FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        container_start_at = @datetime1
        container_end_at = @datetime2

        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{}, [])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })
      end
    end

    test "container start_at is nil, raises a FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        included_start_at = @datetime1
        included_end_at = @datetime2
        container_start_at = nil
        container_end_at = @datetime2

        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })
      end
    end

    test "included start_at is before container start_at, returns an invalid changeset" do
      included_start_at = @datetime1
      included_end_at = @datetime1
      container_start_at = @datetime2
      container_end_at = @datetime2

      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })

      refute changeset.valid?
    end

    test "included end_at is nil and container end_at is set, returns an invalid changeset" do
      included_start_at = @datetime1
      included_end_at = nil
      container_start_at = @datetime2
      container_end_at = @datetime2

      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })

      refute changeset.valid?
    end

    test "included end_at is after container end_at is set, returns an invalid changeset" do
      included_start_at = @datetime1
      included_end_at = @datetime2
      container_start_at = @datetime1
      container_end_at = @datetime1

      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })

      refute changeset.valid?
    end

    test "included date is in bound of container date, returns a valid changeset" do
      included_start_at = @datetime2
      included_end_at = @datetime2
      container_start_at = @datetime1
      container_end_at = @datetime3

      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })

      assert changeset.valid?
    end

    test "start_at of included date equal to start_at of container date, returns a valid changeset" do
      included_start_at = @datetime1
      included_end_at = @datetime2
      container_start_at = @datetime1
      container_end_at = @datetime3

      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })

      assert changeset.valid?
    end

    test "end_at of included date equal to end_at of container date, returns a valid changeset" do
      included_start_at = @datetime2
      included_end_at = @datetime3
      container_start_at = @datetime1
      container_end_at = @datetime3

      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })

      assert changeset.valid?
    end

    test "end_at of included date is set and end_at of container date is nil, returns a valid changeset" do
      included_start_at = @datetime2
      included_end_at = @datetime3
      container_start_at = @datetime1
      container_end_at = nil

      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{start_at: included_start_at, end_at: included_end_at}, [
          :start_at,
          :end_at
        ])
        |> validate_datetime_inclusion(:start_at, :end_at, %{
          start_at: container_start_at,
          end_at: container_end_at
        })

      assert changeset.valid?
    end

    test "all datetimes are nil, returns an valid changeset" do
      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{}, [])
        |> validate_datetime_inclusion(:start_at, :end_at, %{start_at: nil, end_at: nil})

      assert changeset.valid?
    end
  end

  describe "validate_datetime_inclusion/6" do
    test "can accept different key name for start_at and end_at for the container period- all datetimes are nil, returns an valid changeset" do
      changeset =
        %PeriodSchema{}
        |> Ecto.Changeset.cast(%{}, [])
        |> validate_datetime_inclusion(
          :start_at,
          :end_at,
          %{started_at: nil, ended_at: nil},
          :started_at,
          :ended_at
        )

      assert changeset.valid?
    end
  end
end
