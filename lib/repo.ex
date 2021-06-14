defmodule AntlUtilsEcto.Repo do
  @moduledoc """
  Set of utils for Ecto about Repo
  """
  defmacro __using__(_opts) do
    quote bind_quoted: [] do
      def paginate(queryable, page_size, page_number) do
        repo = unquote(__MODULE__)

        pagination_query = queryable |> AntlUtilsEcto.Paginator.paginate(page_size, page_number)

        %{total: repo.aggregate(queryable, :count, :id), data: repo.all(pagination_query)}
      end
    end
  end
end
