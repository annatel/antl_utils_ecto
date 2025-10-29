defmodule AntlUtilsEcto.Repo do
  @moduledoc """
  Set of utils for Ecto about Repo
  """
  defmacro __using__(_opts) do
    quote bind_quoted: [] do
      @type paginate_result(resource_type) :: %{
              :data => [resource_type],
              :total => integer,
              :page_number => integer,
              :page_size => integer
            }

      def paginate(queryable, page_size, page_number) do
        repo = unquote(__MODULE__)

        pagination_query = queryable |> AntlUtilsEcto.Paginator.paginate(page_size, page_number)

        %{
          total: repo.aggregate(queryable, :count),
          data: repo.all(pagination_query),
          page_number: page_number,
          page_size: page_size
        }
      end
    end
  end
end
