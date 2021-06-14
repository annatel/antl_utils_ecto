defmodule AntlUtilsEcto.Changeset do
  @moduledoc """
  Set of utils for Ecto.Changeset
  """
  import Ecto.Changeset,
    only: [
      add_error: 3,
      fetch_field: 2,
      get_field: 2,
      traverse_errors: 2,
      validate_change: 3,
      validate_required: 3
    ]

  @doc """
  A helper that transforms changeset errors into a map of messages.

  ## Examples

    iex> changeset = Ecto.Changeset.change({%{}, %{password: :string}}) |> Ecto.Changeset.cast(%{password: 123}, [:password])
    iex> assert "is invalid" in AntlUtilsEcto.Changeset.errors_on(changeset).password
    iex> assert %{password: ["is invalid"]} = AntlUtilsEcto.Changeset.errors_on(changeset)
  """
  @spec errors_on(Ecto.Changeset.t()) :: %{optional(atom) => [binary]}
  def errors_on(changeset) do
    traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @spec validate_required_one_exclusive(Ecto.Changeset.t(), [any], keyword) ::
          Ecto.Changeset.t()
  def validate_required_one_exclusive(%Ecto.Changeset{} = changeset, fields, opts \\ [])
      when length(fields) > 0 do
    key = Keyword.get(opts, :key, List.first(fields)) |> to_string() |> String.to_atom()

    case Enum.count(fields, &get_field(changeset, &1)) do
      0 ->
        changeset
        |> add_error(key, "one of #{inspect(fields)} must be present")

      1 ->
        changeset

      _ ->
        changeset
        |> add_error(key, "only one of #{inspect(fields)} must be present")
    end
  end

  @spec validate_required_any(Ecto.Changeset.t(), list, keyword) :: Ecto.Changeset.t()
  def validate_required_any(%Ecto.Changeset{} = changeset, fields, opts \\ [])
      when length(fields) > 1 do
    key = Keyword.get(opts, :key, List.first(fields)) |> to_string() |> String.to_atom()
    min = Keyword.get(opts, :min, 1)

    message = Keyword.get(opts, :message, "at least #{min} of #{inspect(fields)} can't be blank")

    if Enum.count(fields, &get_field(changeset, &1)) < min do
      changeset |> add_error(key, message)
    else
      changeset
    end
  end

  @spec validate_required_if(Ecto.Changeset.t(), any, atom, any, keyword) :: Ecto.Changeset.t()
  def validate_required_if(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        expected_value,
        opts \\ []
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)
    conditional_field_value = get_field(changeset, conditional_field)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be blank when #{conditional_field} is #{expected_value}"
      )

    if conditional_field_value == expected_value do
      changeset |> validate_required(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_required_unless(Ecto.Changeset.t(), any, atom, any, keyword) ::
          Ecto.Changeset.t()
  def validate_required_unless(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        expected_value,
        opts \\ []
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)
    conditional_field_value = get_field(changeset, conditional_field)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be blank unless #{conditional_field} is #{expected_value}"
      )

    unless conditional_field_value == expected_value do
      changeset |> validate_required(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_required_any_if(Ecto.Changeset.t(), any, atom, any, keyword) ::
          Ecto.Changeset.t()
  def validate_required_any_if(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        expected_value,
        opts \\ []
      )
      when length(fields) > 1 and is_atom(conditional_field) do
    min = Keyword.get(opts, :min, 1)
    fields = List.wrap(fields)
    conditional_field_value = get_field(changeset, conditional_field)

    message =
      Keyword.get(
        opts,
        :message,
        "at least #{min} of #{inspect(fields)} can't be blank when #{conditional_field} is #{expected_value}"
      )

    if conditional_field_value == expected_value do
      changeset |> validate_required_any(fields, Keyword.merge(opts, message: message))
    else
      changeset
    end
  end

  @spec validate_required_any_unless(Ecto.Changeset.t(), any, atom, any, keyword) ::
          Ecto.Changeset.t()
  def validate_required_any_unless(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        expected_value,
        opts \\ []
      )
      when is_atom(conditional_field) do
    min = Keyword.get(opts, :min, 1)
    fields = List.wrap(fields)
    conditional_field_value = get_field(changeset, conditional_field)

    message =
      Keyword.get(
        opts,
        :message,
        "at least #{min} of #{inspect(fields)} can't be blank unless #{conditional_field} is #{expected_value}"
      )

    unless conditional_field_value == expected_value do
      changeset |> validate_required_any(fields, Keyword.merge(opts, message: message))
    else
      changeset
    end
  end

  @spec validate_required_with(Ecto.Changeset.t(), any, atom | [atom], keyword) ::
          Ecto.Changeset.t()
  def validate_required_with(changeset, fields, conditional_fields, opts \\ [])

  def validate_required_with(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        opts
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)

    opts =
      opts |> Keyword.put_new(:message, "can't be blank when #{conditional_field} is present")

    changeset
    |> validate_required_with(fields, [conditional_field], opts)
  end

  def validate_required_with(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be blank when any of #{inspect(conditional_fields)} are present"
      )

    if Enum.any?(conditional_fields, &(not is_nil(get_field(changeset, &1)))) do
      changeset |> validate_required(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_required_with_all(Ecto.Changeset.t(), any, [atom], keyword) ::
          Ecto.Changeset.t()
  def validate_required_with_all(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts \\ []
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be blank when #{Enum.join(conditional_fields, " and ")} are present"
      )

    if Enum.all?(conditional_fields, &(not is_nil(get_field(changeset, &1)))) do
      changeset |> validate_required(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_required_without(Ecto.Changeset.t(), any, atom | [atom], keyword) ::
          Ecto.Changeset.t()
  def validate_required_without(changeset, fields, conditional_fields, opts \\ [])

  def validate_required_without(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        opts
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)

    opts =
      opts
      |> Keyword.put_new(:message, "can't be blank when #{conditional_field} is not present")

    changeset
    |> validate_required_without(fields, [conditional_field], opts)
  end

  def validate_required_without(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be blank when any of #{inspect(conditional_fields)} is not present"
      )

    if Enum.any?(conditional_fields, &is_nil(get_field(changeset, &1))) do
      changeset |> validate_required(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_required_without_all(Ecto.Changeset.t(), any, [atom], keyword) ::
          Ecto.Changeset.t()
  def validate_required_without_all(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts \\ []
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be blank when #{Enum.join(conditional_fields, " and ")} are not present"
      )

    if Enum.all?(conditional_fields, &is_nil(get_field(changeset, &1))) do
      changeset |> validate_required(fields, message: message)
    else
      changeset
    end
  end

  @doc """
  Validates the given `fields` change are empty or unchanged.
  """
  @spec validate_empty(Ecto.Changeset.t(), any, keyword) :: Ecto.Changeset.t()
  def validate_empty(%Ecto.Changeset{} = changeset, fields, opts \\ []) do
    fields = List.wrap(fields)
    message = Keyword.get(opts, :message, "can't be set")

    fields
    |> Enum.reduce(changeset, fn field, acc ->
      acc
      |> validate_change(field, fn field, _field_changeset ->
        [{field, message}]
      end)
    end)
  end

  @spec validate_empty_if(Ecto.Changeset.t(), any, atom, any, keyword) :: Ecto.Changeset.t()
  def validate_empty_if(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        expected_value,
        opts \\ []
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)
    conditional_field_value = get_field(changeset, conditional_field)

    message =
      Keyword.get(opts, :message, "can't be set when #{conditional_field} is #{expected_value}")

    if conditional_field_value == expected_value do
      changeset |> validate_empty(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_empty_unless(Ecto.Changeset.t(), any, atom, any, keyword) :: Ecto.Changeset.t()
  def validate_empty_unless(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        expected_value,
        opts \\ []
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)
    conditional_field_value = get_field(changeset, conditional_field)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be set unless #{conditional_field} is #{expected_value}"
      )

    unless conditional_field_value == expected_value do
      changeset |> validate_empty(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_empty_with(Ecto.Changeset.t(), any, atom | [atom], keyword) ::
          Ecto.Changeset.t()
  def validate_empty_with(changeset, fields, conditional_fields, opts \\ [])

  def validate_empty_with(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        opts
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)

    opts = opts |> Keyword.put_new(:message, "can't be set when #{conditional_field} is present")

    changeset
    |> validate_empty_with(fields, [conditional_field], opts)
  end

  def validate_empty_with(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be set when any of #{inspect(conditional_fields)} are present"
      )

    if Enum.any?(conditional_fields, &(not is_nil(get_field(changeset, &1)))) do
      changeset |> validate_empty(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_empty_with_all(Ecto.Changeset.t(), any, [atom], keyword) :: Ecto.Changeset.t()
  def validate_empty_with_all(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts \\ []
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be blank when #{Enum.join(conditional_fields, " and ")} are present"
      )

    if Enum.all?(conditional_fields, &(not is_nil(get_field(changeset, &1)))) do
      changeset |> validate_empty(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_empty_without(Ecto.Changeset.t(), any, atom | [atom], keyword) ::
          Ecto.Changeset.t()
  def validate_empty_without(changeset, fields, conditional_fields, opts \\ [])

  def validate_empty_without(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_field,
        opts
      )
      when is_atom(conditional_field) do
    fields = List.wrap(fields)

    opts =
      opts |> Keyword.put_new(:message, "can't be set when #{conditional_field} is not present")

    changeset
    |> validate_empty_without(fields, [conditional_field], opts)
  end

  def validate_empty_without(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be set when any of #{inspect(conditional_fields)} is not present"
      )

    if Enum.any?(conditional_fields, &is_nil(get_field(changeset, &1))) do
      changeset |> validate_empty(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_empty_without_all(Ecto.Changeset.t(), any, [atom], keyword) ::
          Ecto.Changeset.t()
  def validate_empty_without_all(
        %Ecto.Changeset{} = changeset,
        fields,
        conditional_fields,
        opts \\ []
      )
      when length(conditional_fields) > 0 do
    fields = List.wrap(fields)

    message =
      Keyword.get(
        opts,
        :message,
        "can't be set when #{Enum.join(conditional_fields, " and ")} are not present"
      )

    if Enum.all?(conditional_fields, &is_nil(get_field(changeset, &1))) do
      changeset |> validate_empty(fields, message: message)
    else
      changeset
    end
  end

  @spec validate_datetime_lt(Ecto.Changeset.t(), atom, atom | nil | DateTime.t(), keyword) ::
          Ecto.Changeset.t()
  def validate_datetime_lt(changeset, datetime_key, referal, opts \\ [])

  def validate_datetime_lt(
        %Ecto.Changeset{} = changeset,
        datetime_key,
        referal_datetime_key,
        opts
      )
      when is_atom(datetime_key) and is_atom(referal_datetime_key) and
             not is_nil(referal_datetime_key) do
    opts = Keyword.put_new(opts, :message, "should be before #{referal_datetime_key}")

    {_, referal_datetime} = fetch_field(changeset, referal_datetime_key)

    validate_datetime_lt(changeset, datetime_key, referal_datetime, opts)
  end

  def validate_datetime_lt(
        %Ecto.Changeset{} = changeset,
        datetime_key,
        referal_datetime,
        opts
      )
      when is_atom(datetime_key) do
    message = Keyword.get(opts, :message, "should be before #{referal_datetime}")

    {_, datetime} = fetch_field(changeset, datetime_key)

    if datetime_lt?(datetime, referal_datetime) do
      changeset
    else
      changeset |> add_error(datetime_key, message)
    end
  end

  @spec validate_datetime_lte(Ecto.Changeset.t(), atom, atom | nil | DateTime.t(), keyword) ::
          Ecto.Changeset.t()
  def validate_datetime_lte(changeset, datetime_key, referal, opts \\ [])

  def validate_datetime_lte(
        %Ecto.Changeset{} = changeset,
        datetime_key,
        referal_datetime_key,
        opts
      )
      when is_atom(datetime_key) and is_atom(referal_datetime_key) and
             not is_nil(referal_datetime_key) do
    opts = Keyword.put_new(opts, :message, "should be before or equal to #{referal_datetime_key}")

    {_, referal_datetime} = fetch_field(changeset, referal_datetime_key)

    validate_datetime_lte(changeset, datetime_key, referal_datetime, opts)
  end

  def validate_datetime_lte(%Ecto.Changeset{} = changeset, datetime_key, referal_datetime, opts)
      when is_atom(datetime_key) do
    message = Keyword.get(opts, :message, "should be before or equal to #{referal_datetime}")

    {_, datetime} = fetch_field(changeset, datetime_key)

    if datetime_lte?(datetime, referal_datetime) do
      changeset
    else
      changeset |> add_error(datetime_key, message)
    end
  end

  @spec validate_datetime_gt(Ecto.Changeset.t(), atom, atom | nil | DateTime.t(), keyword) ::
          Ecto.Changeset.t()
  def validate_datetime_gt(changeset, datetime_key, referal, opts \\ [])

  def validate_datetime_gt(
        %Ecto.Changeset{} = changeset,
        datetime_key,
        referal_datetime_key,
        opts
      )
      when is_atom(datetime_key) and is_atom(referal_datetime_key) and
             not is_nil(referal_datetime_key) do
    opts = Keyword.put_new(opts, :message, "should be after #{referal_datetime_key}")

    {_, referal_datetime} = fetch_field(changeset, referal_datetime_key)

    validate_datetime_gt(changeset, datetime_key, referal_datetime, opts)
  end

  def validate_datetime_gt(%Ecto.Changeset{} = changeset, datetime_key, referal_datetime, opts)
      when is_atom(datetime_key) do
    message = Keyword.get(opts, :message, "should be after #{referal_datetime}")

    {_, datetime} = fetch_field(changeset, datetime_key)

    if datetime_gt?(datetime, referal_datetime) do
      changeset
    else
      changeset |> add_error(datetime_key, message)
    end
  end

  @spec validate_datetime_gte(Ecto.Changeset.t(), atom, atom | nil | DateTime.t(), keyword) ::
          Ecto.Changeset.t()
  def validate_datetime_gte(changeset, datetime_key, referal, opts \\ [])

  def validate_datetime_gte(
        %Ecto.Changeset{} = changeset,
        datetime_key,
        referal_datetime_key,
        opts
      )
      when is_atom(datetime_key) and is_atom(referal_datetime_key) and
             not is_nil(referal_datetime_key) do
    opts = Keyword.put_new(opts, :message, "should be after or equal to #{referal_datetime_key}")

    {_, referal_datetime} = fetch_field(changeset, referal_datetime_key)

    validate_datetime_gte(changeset, datetime_key, referal_datetime, opts)
  end

  def validate_datetime_gte(%Ecto.Changeset{} = changeset, datetime_key, referal_datetime, opts)
      when is_atom(datetime_key) do
    message = Keyword.get(opts, :message, "should be after or equal to #{referal_datetime}")

    {_, datetime} = fetch_field(changeset, datetime_key)

    if datetime_gte?(datetime, referal_datetime) do
      changeset
    else
      changeset |> add_error(datetime_key, message)
    end
  end

  @spec validate_datetime_inclusion(Ecto.Changeset.t(), atom, atom, map, atom, atom) ::
          Ecto.Changeset.t()
  def validate_datetime_inclusion(
        %Ecto.Changeset{} = changeset,
        start_at_key,
        end_at_key,
        period,
        period_start_at_key,
        period_end_at_key
      )
      when is_atom(period_start_at_key) and is_atom(period_end_at_key) do
    container_period = %{
      start_at: Map.get(period, period_start_at_key),
      end_at: Map.get(period, period_end_at_key)
    }

    validate_datetime_inclusion(changeset, start_at_key, end_at_key, container_period)
  end

  @spec validate_datetime_inclusion(
          Ecto.Changeset.t(),
          atom,
          atom,
          AntlUtilsElixir.DateTime.Period.t()
        ) ::
          Ecto.Changeset.t()
  def validate_datetime_inclusion(%Ecto.Changeset{} = changeset, _, _, %{
        start_at: nil,
        end_at: nil
      }) do
    changeset
  end

  def validate_datetime_inclusion(
        %Ecto.Changeset{} = changeset,
        start_at_key,
        end_at_key,
        %{start_at: _, end_at: _} = container_period
      )
      when is_atom(start_at_key) and is_atom(end_at_key) do
    {_, included_start_at} = fetch_field(changeset, start_at_key)
    {_, included_end_at} = fetch_field(changeset, end_at_key)

    included_period = %{start_at: included_start_at, end_at: included_end_at}

    unless AntlUtilsElixir.DateTime.Period.included?(included_period, container_period) do
      changeset
      |> add_error(
        start_at_key,
        "#{start_at_key} and #{end_at_key} are out of bound [#{container_period.start_at}, #{container_period.end_at}]"
      )
    else
      changeset
    end
  end

  defp datetime_gt?(nil, nil), do: true
  defp datetime_gt?(_, nil), do: false
  defp datetime_gt?(nil, %DateTime{}), do: true

  defp datetime_gt?(%DateTime{} = end_at, %DateTime{} = start_at),
    do: AntlUtilsElixir.DateTime.Comparison.gt?(end_at, start_at)

  defp datetime_gte?(nil, nil), do: true
  defp datetime_gte?(_, nil), do: false
  defp datetime_gte?(nil, %DateTime{}), do: true

  defp datetime_gte?(%DateTime{} = end_at, %DateTime{} = start_at),
    do: AntlUtilsElixir.DateTime.Comparison.gte?(end_at, start_at)

  defp datetime_lt?(nil, nil), do: true
  defp datetime_lt?(_, nil), do: true
  defp datetime_lt?(nil, %DateTime{}), do: false

  defp datetime_lt?(%DateTime{} = end_at, %DateTime{} = start_at),
    do: AntlUtilsElixir.DateTime.Comparison.lt?(end_at, start_at)

  defp datetime_lte?(nil, nil), do: true
  defp datetime_lte?(_, nil), do: true
  defp datetime_lte?(nil, %DateTime{}), do: false

  defp datetime_lte?(%DateTime{} = end_at, %DateTime{} = start_at),
    do: AntlUtilsElixir.DateTime.Comparison.lte?(end_at, start_at)
end
