defmodule AntlUtilsEcto.Paginator do
  @moduledoc """
  Documentation for Paginator.
  """

  import Ecto.Query, only: [limit: 2, offset: 2]

  @per_page 100

  @doc """
  Paginate.

  ## Examples

    iex> queryable = from u in "products"
    #Ecto.Query<from p0 in "products">
    iex> Paginator.paginate(queryable, 1)
    #Ecto.Query<from p0 in "products", limit: ^100, offset: ^0>
    iex> Paginator.paginate(queryable, 2)
    #Ecto.Query<from p0 in "products", limit: ^100, offset: ^100>
    iex> Paginator.paginate(queryable, 3)
    #Ecto.Query<from p0 in "products", limit: ^100, offset: ^200>
    iex> Paginator.paginate(queryable, 3, [per_page: 10])
    #Ecto.Query<from p0 in "products", limit: ^10, offset: ^20>

  """
  @spec paginate(any, number, keyword) :: Ecto.Query.t()
  def paginate(queryable, page, opts \\ []) when page > 0 do
    per_page = Keyword.get(opts, :per_page, @per_page)

    offset = per_page * (page - 1)

    queryable
    |> limit(^per_page)
    |> offset(^offset)
  end
end
