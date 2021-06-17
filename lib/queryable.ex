defmodule AntlUtilsEcto.Queryable do
  @moduledoc """
  Superpower your schemas.
  """

  @callback queryable() :: Ecto.Queryable.t()

  @callback include(Ecto.Queryable.t(), list) :: Ecto.Queryable.t()
  @callback filter(Ecto.Queryable.t(), keyword) :: Ecto.Queryable.t()
  @callback order_by(Ecto.Queryable.t(), list | keyword) :: Ecto.Queryable.t()
  @callback paginate(Ecto.Queryable.t(), pos_integer, pos_integer) :: Ecto.Queryable.t()
  @callback search(Ecto.Queryable.t(), binary) :: Ecto.Queryable.t()
  @callback select_fields(Ecto.Queryable.t(), list()) :: Ecto.Queryable.t()

  defmacro __using__(opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      import Ecto.Query, only: [dynamic: 2, where: 2]

      @searchable_fields Keyword.get(unquote(opts), :searchable_fields, [:id])
      @soft_delete_field Keyword.get(unquote(opts), :soft_delete_field)
      @has_soft_delete? not is_nil(@soft_delete_field)

      def queryable() do
        queryable = Keyword.get(unquote(opts), :base_schema, __MODULE__)

        if @has_soft_delete?,
          do: queryable |> AntlUtilsEcto.Query.where(@soft_delete_field, nil),
          else: queryable
      end

      defoverridable queryable: 0

      def searchable_fields(), do: @searchable_fields

      @spec include(Ecto.Queryable.t(), list()) :: Ecto.Queryable.t()
      def include(queryable, includes) when is_list(includes),
        do: Enum.reduce(includes, queryable, &include_assoc(&2, &1))

      def filter(queryable, filters),
        do: Enum.reduce(filters, queryable, &filter_by_field(&2, &1))

      def order_by(queryable, order_bys),
        do: unquote(__MODULE__).order_by(queryable, order_bys)

      def paginate(queryable, page_size, page_number),
        do: unquote(__MODULE__).paginate(queryable, page_size, page_number)

      def search(queryable, search_query, metadata \\ [], searchable_fields \\ @searchable_fields)
      def search(queryable, nil, _metadata, _searchable_fields), do: queryable
      def search(queryable, "", _metadata, _searchable_fields), do: queryable

      def search(queryable, search_query, metadata, searchable_fields)
          when is_binary(search_query) and is_list(metadata),
          do: where(queryable, ^search_where_query(search_query, metadata, searchable_fields))

      def select_fields(queryable, fields),
        do: unquote(__MODULE__).select_fields(queryable, fields)

      defp search_where_query(search_query, [], searchable_fields)
           when is_list(searchable_fields) do
        searchable_fields
        |> Enum.reduce(Ecto.Query.dynamic(false), &search_by_field(&2, {&1, search_query}))
      end

      defp search_where_query(search_query, metadata, searchable_fields)
           when length(metadata) > 0 and is_list(searchable_fields) do
        searchable_fields
        |> Enum.reduce(
          Ecto.Query.dynamic(false),
          &search_by_field(&2, {&1, search_query}, metadata)
        )
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defp include_assoc(queryable, _), do: queryable

      if @has_soft_delete? do
        defp filter_by_field(queryable, {:with_trashed, true}),
          do: queryable |> AntlUtilsEcto.Query.or_where_not(@soft_delete_field, nil)

        defp filter_by_field(queryable, {:only_trashed, true}),
          do: queryable |> AntlUtilsEcto.Query.where_not(@soft_delete_field, nil)
      end

      defp filter_by_field(queryable, field),
        do: unquote(__MODULE__).filter_by_field(queryable, field)

      defp search_by_field(dynamic, field),
        do: unquote(__MODULE__).search_by_field(dynamic, field)

      defp search_by_field(dynamic, field, metadata),
        do: unquote(__MODULE__).search_by_field(dynamic, field, metadata)
    end
  end

  import Ecto.Query, only: [dynamic: 2]

  @spec filter_by_field(any, {any, any}) :: Ecto.Query.t()
  def filter_by_field(queryable, {key, value}) do
    queryable |> AntlUtilsEcto.Query.where(key, value)
  end

  @spec order_by(Ecto.Queryable.t(), list) :: Ecto.Queryable.t()
  def order_by(queryable, []), do: queryable

  def order_by(queryable, order_bys) when is_list(order_bys) do
    queryable |> Ecto.Query.order_by(^order_bys)
  end

  @spec paginate(any, pos_integer(), pos_integer()) :: Ecto.Query.t()
  def paginate(queryable, page_size, page_number) do
    queryable |> AntlUtilsEcto.Paginator.paginate(page_size, page_number)
  end

  @spec search_by_field(Ecto.Query.DynamicExpr.t(), {any, binary}) :: Ecto.Query.DynamicExpr.t()
  def search_by_field(dynamic, {key, value}) do
    like_value = "%#{String.replace(value, "%", "\\%")}%"
    dynamic([q], ^dynamic or like(type(fragment("?", field(q, ^key)), :string), ^like_value))
  end

  @spec search_by_field(Ecto.Query.DynamicExpr.t(), {any, binary}, list()) ::
          Ecto.Query.DynamicExpr.t()
  def search_by_field(dynamic, {key, value}, metadata) when is_list(metadata) do
    like_value = "%#{String.replace(value, "%", "\\%")}%"
    dynamic([q], ^dynamic or like(type(fragment("?", field(q, ^key)), :string), ^like_value))
  end

  @spec select_fields(Ecto.Queryable.t(), nil | list) :: Ecto.Queryable.t()
  def select_fields(queryable, nil), do: queryable
  def select_fields(queryable, []), do: queryable

  def select_fields(queryable, fields) when is_list(fields),
    do: queryable |> Ecto.Query.select(^fields)
end
