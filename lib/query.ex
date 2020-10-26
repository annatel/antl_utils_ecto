defmodule AntlUtilsEcto.Query do
  @moduledoc """
  Set of utils for Ecto.Query
  """
  import Ecto.Query, only: [from: 2]

  @spec where(any, atom, nil | binary | [any] | integer) :: Ecto.Query.t()
  def where(queryable, key, nil) when is_atom(key) do
    from(q in queryable, where: is_nil(field(q, ^key)))
  end

  def where(queryable, key, value) when is_atom(key) and length(value) > 0 do
    from(q in queryable, where: field(q, ^key) in ^value)
  end

  # def where(queryable, key, value) when is_atom(key) and is_boolean(value) do
  #   from(q in queryable, where: field(q, ^key) == ^value)
  # end

  def where(queryable, key, value) when is_atom(key) do
    from(q in queryable, where: field(q, ^key) == ^value)
  end

  @spec where_like(any, atom, binary) :: Ecto.Query.t()
  def where_like(queryable, key, value) when is_atom(key) and is_binary(value) do
    like_value = "%#{String.replace(value, "%", "\\%")}%"
    from(q in queryable, where: like(field(q, ^key), ^like_value))
  end

  @spec or_where(any, atom, nil | binary | [any]) :: Ecto.Query.t()
  def or_where(queryable, key, nil) when is_atom(key) do
    from(q in queryable, or_where: is_nil(field(q, ^key)))
  end

  def or_where(queryable, key, value) when is_atom(key) and length(value) > 0 do
    from(q in queryable, or_where: field(q, ^key) in ^value)
  end

  def or_where(queryable, key, value) when is_atom(key) do
    from(q in queryable, or_where: field(q, ^key) == ^value)
  end

  @spec or_where_like(any, atom, binary) :: Ecto.Query.t()
  def or_where_like(queryable, key, value) when is_atom(key) and is_binary(value) do
    like_value = "%#{String.replace(value, "%", "\\%")}%"
    from(q in queryable, or_where: like(field(q, ^key), ^like_value))
  end

  @spec where_in_period(any, atom, atom, DateTime.t()) :: Ecto.Query.t()
  def where_in_period(queryable, start_at_key, end_at_key, %DateTime{} = datetime)
      when is_atom(start_at_key) and is_atom(end_at_key) do
    from(q in queryable,
      where:
        field(q, ^start_at_key) <= ^datetime and
          (field(q, ^end_at_key) > ^datetime or is_nil(field(q, ^end_at_key)))
    )
  end

  @spec order_by(any, atom, :asc | :desc) :: Ecto.Query.t()
  def order_by(queryable, key, order) when is_atom(key) and order in [:asc, :desc] do
    from(q in queryable, order_by: [{^order, field(q, ^key)}])
  end
end
