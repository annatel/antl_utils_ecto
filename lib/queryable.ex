defmodule AntlUtilsEcto.Queryable do
  @moduledoc """
  Superpower your schemas.
  """

  @callback queryable() :: Ecto.Queryable.t()
  @callback filter(Ecto.Queryable.t(), keyword) :: Ecto.Queryable.t()
  @callback search(Ecto.Queryable.t(), binary) :: Ecto.Queryable.t()

  defmacro __using__(opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      import Ecto.Query, only: [dynamic: 2, where: 2]

      @searchable_fields Keyword.get(unquote(opts), :searchable_fields, [:id])

      def queryable(), do: Keyword.get(unquote(opts), :base_schema, __MODULE__)
      defoverridable queryable: 0

      def searchable_fields(), do: @searchable_fields

      def filter(queryable, filters),
        do: Enum.reduce(filters, queryable, &filter_by_field(&1, &2))

      def search(queryable, search_query, metadata \\ [], searchable_fields \\ @searchable_fields)
      def search(queryable, nil, _metadata, _searchable_fields), do: queryable
      def search(queryable, "", _metadata, _searchable_fields), do: queryable

      def search(queryable, search_query, metadata, searchable_fields)
          when is_binary(search_query) and is_list(metadata),
          do: where(queryable, ^search_where_query(search_query, metadata, searchable_fields))

      defp search_where_query(search_query, [], searchable_fields)
           when is_list(searchable_fields) do
        searchable_fields
        |> Enum.reduce(Ecto.Query.dynamic(false), &search_by_field({&1, search_query}, &2))
      end

      defp search_where_query(search_query, metadata, searchable_fields)
           when length(metadata) > 0 and is_list(searchable_fields) do
        searchable_fields
        |> Enum.reduce(
          Ecto.Query.dynamic(false),
          &search_by_field({&1, search_query}, &2, metadata)
        )
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defp filter_by_field(field, queryable),
        do: unquote(__MODULE__).filter_by_field(field, queryable)

      defp search_by_field(field, dynamic),
        do: unquote(__MODULE__).search_by_field(field, dynamic)

      defp search_by_field(field, dynamic, metadata),
        do: unquote(__MODULE__).search_by_field(field, dynamic, metadata)
    end
  end

  import Ecto.Query, only: [dynamic: 2]

  @spec filter_by_field({any, any}, any) :: Ecto.Query.t()
  def filter_by_field({key, value}, queryable) do
    queryable |> AntlUtilsEcto.Query.where(key, value)
  end

  @spec search_by_field({any, binary}, any) :: Ecto.Query.DynamicExpr.t()
  def search_by_field({key, value}, dynamic) do
    like_value = "%#{String.replace(value, "%", "\\%")}%"
    dynamic([q], ^dynamic or like(field(q, ^key), ^like_value))
  end

  @spec search_by_field({any, binary}, any, list()) :: Ecto.Query.DynamicExpr.t()
  def search_by_field({key, value}, dynamic, metadata) when is_list(metadata) do
    like_value = "%#{String.replace(value, "%", "\\%")}%"
    dynamic([q], ^dynamic or like(field(q, ^key), ^like_value))
  end
end
