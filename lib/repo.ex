defmodule AntlUtilsEcto.Repo do
  @moduledoc """
  Set of utils for Ecto about Repo
  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @repo Keyword.fetch!(opts, :repo)

      def paginate(queryable, page_number, page_size) do
        pagination_query = queryable |> AntlUtilsEcto.Paginator.paginate(page_number, page_size)

        %{total: @repo.aggregate(queryable, :count, :id), data: @repo.all(pagination_query)}
      end
    end
  end
end
