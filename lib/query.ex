defmodule AntlUtilsEcto.Query do
  @moduledoc """
  Set of utils for Ecto.Query
  """
  @type status :: :ended | :ongoing | :scheduled

  import Ecto.Query, only: [dynamic: 2, from: 2]

  @spec where(any, atom, nil | binary | [any] | integer | boolean) :: Ecto.Query.t()
  def where(queryable, key, nil) when is_atom(key) do
    from(q in queryable, where: is_nil(field(q, ^key)))
  end

  def where(queryable, key, value) when is_atom(key) and is_list(value) do
    from(q in queryable, where: field(q, ^key) in ^value)
  end

  def where(queryable, key, value) when is_atom(key) do
    from(q in queryable, where: field(q, ^key) == ^value)
  end

  @spec where_not(any, atom, nil | binary | [any] | integer | boolean) :: Ecto.Query.t()
  def where_not(queryable, key, nil) when is_atom(key) do
    from(q in queryable, where: not is_nil(field(q, ^key)))
  end

  def where_not(queryable, key, value) when is_atom(key) and length(value) > 0 do
    from(q in queryable, where: field(q, ^key) not in ^value)
  end

  def where_not(queryable, key, value) when is_atom(key) do
    from(q in queryable, where: field(q, ^key) != ^value)
  end

  @spec where_like(any, atom, binary) :: Ecto.Query.t()
  def where_like(queryable, key, value) when is_atom(key) and is_binary(value) do
    like_value = "%#{String.replace(value, "%", "\\%")}%"
    from(q in queryable, where: like(field(q, ^key), ^like_value))
  end

  @spec where_period_status(Ecto.Queryable.t(), status | list(status), atom, atom, DateTime.t()) ::
          Ecto.Query.t()
  def where_period_status(
        queryable,
        status,
        start_at_key,
        end_at_key,
        %DateTime{} = datetime
      ) do
    conditions =
      status
      |> List.wrap()
      |> Enum.reduce(
        Ecto.Query.dynamic(false),
        &status_dynamic_expression(&2, &1, start_at_key, end_at_key, datetime)
      )

    from(q in queryable, where: ^conditions)
  end

  @spec or_where(any, atom, nil | binary | [any]) :: Ecto.Query.t()
  def or_where(queryable, key, nil) when is_atom(key) do
    from(q in queryable, or_where: is_nil(field(q, ^key)))
  end

  def or_where(queryable, key, value) when is_atom(key) and is_list(value) do
    from(q in queryable, or_where: field(q, ^key) in ^value)
  end

  def or_where(queryable, key, value) when is_atom(key) do
    from(q in queryable, or_where: field(q, ^key) == ^value)
  end

  @spec or_where_not(any, atom, nil | binary | [any]) :: Ecto.Query.t()
  def or_where_not(queryable, key, nil) when is_atom(key) do
    from(q in queryable, or_where: not is_nil(field(q, ^key)))
  end

  def or_where_not(queryable, key, value) when is_atom(key) and length(value) > 0 do
    from(q in queryable, or_where: field(q, ^key) not in ^value)
  end

  def or_where_not(queryable, key, value) when is_atom(key) do
    from(q in queryable, or_where: field(q, ^key) != ^value)
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
        ^status_dynamic_expression(
          Ecto.Query.dynamic(false),
          :ongoing,
          start_at_key,
          end_at_key,
          datetime
        )
    )
  end

  defp status_dynamic_expression(
         dynamic,
         :ongoing,
         start_at_key,
         end_at_key,
         %DateTime{} = datetime
       ) do
    dynamic(
      [q],
      ^dynamic or
        (field(q, ^start_at_key) <= ^datetime and
           (field(q, ^end_at_key) > ^datetime or is_nil(field(q, ^end_at_key))))
    )
  end

  defp status_dynamic_expression(
         dynamic,
         :ended,
         start_at_key,
         end_at_key,
         %DateTime{} = datetime
       ) do
    dynamic(
      [q],
      ^dynamic or (field(q, ^start_at_key) <= ^datetime and field(q, ^end_at_key) <= ^datetime)
    )
  end

  defp status_dynamic_expression(
         dynamic,
         :scheduled,
         start_at_key,
         end_at_key,
         %DateTime{} = datetime
       ) do
    dynamic(
      [q],
      ^dynamic or
        (field(q, ^start_at_key) > ^datetime and
           (field(q, ^end_at_key) > ^datetime or is_nil(field(q, ^end_at_key))))
    )
  end

  @spec json_extract(Macro.t(), Macro.t()) :: Macro.t()
  defmacro json_extract(field, path) do
    quote do
      fragment("JSON_EXTRACT(?, ?)", literal(^unquote(field)), ^unquote(path))
    end
  end

  @spec where_extracted_json_contains(Ecto.Queryable.t(), binary, binary, binary) ::
          Ecto.Queryable.t()
  def where_extracted_json_contains(queryable, field, path, value) when is_binary(value) do
    double_quoted_value_anywhere = "%\"#{String.replace(value, "%", "\\%")}\"%"

    queryable
    |> Ecto.Query.where([_], like(json_extract(field, path), ^double_quoted_value_anywhere))
  end
end
