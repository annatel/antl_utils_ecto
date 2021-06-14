defmodule AntlUtilsEcto.RepoTest do
  use ExUnit.Case

  alias AntlUtilsEcto.TestRepo

  defmodule Schema do
    use Ecto.Schema

    schema "" do
    end
  end

  describe "paginate" do
    test "paginate" do
      for i <- 1..5, do: %Schema{id: i} |> TestRepo.insert!()

      assert %{
               data: [%AntlUtilsEcto.RepoTest.Schema{}],
               page_number: 1,
               page_size: 1,
               total: 1
             } = TestRepo.paginate(Schema, 1, 1)

      assert_received {:all, query}

      assert inspect(query) ==
               "#Ecto.Query<from s0 in AntlUtilsEcto.RepoTest.Schema, select: count(s0.id)>"

      assert_received {:all, query}

      assert inspect(query) ==
               "#Ecto.Query<from s0 in AntlUtilsEcto.RepoTest.Schema, limit: ^..., offset: ^..., select: s0>"
    end
  end
end
