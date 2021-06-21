defmodule AntlUtilsEcto.FactoryTest do
  use ExUnit.Case, async: false
  use AntlUtilsEcto.DataCase

  alias AntlUtilsEcto.TestFactory

  test "insert!" do
    assert %{field1: "a"} = TestFactory.params_for(:test_schema, field1: "a")

    assert %AntlUtilsEcto.TestSchema{id: 1, field1: "a", field2: "b"} =
             TestFactory.insert!(:test_schema)

    assert %AntlUtilsEcto.TestSchema{id: 1, field1: "b", field2: "b"} =
             TestFactory.insert!(:test_schema, field1: "b")
  end
end
