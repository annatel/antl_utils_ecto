defmodule AntlUtilsEcto.FactoryTest do
  use ExUnit.Case, async: false
  use AntlUtilsEcto.DataCase

  alias AntlUtilsEcto.TestFactory

  test "insert!" do
    assert %AntlUtilsEcto.TestSchema{id: 1, field1: "b"} =
             TestFactory.insert!(:test_schema, field1: "b")
  end
end
