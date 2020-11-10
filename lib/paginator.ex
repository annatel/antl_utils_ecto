defmodule AntlUtilsEcto.Paginator do
  @moduledoc """
  Set of utils for Ecto about Pagination
  """

  import Ecto.Query, only: [limit: 2, offset: 2]

  @doc """
  Paginate.

  ## Examples

    iex> queryable = from u in "products"
    #Ecto.Query<from p0 in "products">
    iex> Paginator.paginate(queryable, 1, 100)
    #Ecto.Query<from p0 in "products", limit: ^100, offset: ^0>
    iex> Paginator.paginate(queryable, 2, 100)
    #Ecto.Query<from p0 in "products", limit: ^100, offset: ^100>
    iex> Paginator.paginate(queryable, 3, 100)
    #Ecto.Query<from p0 in "products", limit: ^100, offset: ^200>
    iex> Paginator.paginate(queryable, 3, 10)
    #Ecto.Query<from p0 in "products", limit: ^10, offset: ^20>

  """

  @spec paginate(any, pos_integer, pos_integer) :: Ecto.Query.t()
  def paginate(queryable, page_number, page_size) when page_number > 0 and page_size > 0 do
    offset = page_size * (page_number - 1)

    queryable
    |> limit(^page_size)
    |> offset(^offset)
  end
end
