defmodule AntlUtilsEcto.Factory do
  @callback build(atom, map | list) :: %{:__struct__ => atom, optional(atom) => any}
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @repo Keyword.fetch!(opts, :repo)

      @spec uuid :: <<_::288>>
      defdelegate uuid(), to: __MODULE__

      @spec shortcode_uuid(nil | binary) :: binary
      defdelegate shortcode_uuid(prefix \\ nil), to: __MODULE__

      @spec id :: integer
      defdelegate id(), to: __MODULE__

      @spec shortcode_id(nil | binary) :: binary
      defdelegate shortcode_id(prefix \\ nil), to: __MODULE__

      @spec utc_now :: DateTime.t()
      defdelegate utc_now(), to: __MODULE__

      @spec add(DateTime.t(), integer, System.time_unit()) :: DateTime.t()
      defdelegate add(%DateTime{} = datetime, amount_of_time, time_unit \\ :second),
        to: __MODULE__

      @spec params_for(atom, Enum.t()) :: map
      def params_for(factory_name, attributes \\ []) do
        factory_name |> build(attributes) |> params_for()
      end

      @spec build(atom) :: %{:__struct__ => atom, optional(atom) => any}
      def build(factory_name), do: build(factory_name, [])

      @spec insert!(atom, Enum.t()) :: any
      def insert!(factory_name, attributes)
          when is_atom(factory_name) or is_tuple(factory_name) do
        factory_name |> build(attributes) |> insert!()
      end

      @spec insert!(atom | tuple | struct) :: struct
      def insert!(factory_name) when is_atom(factory_name) or is_tuple(factory_name) do
        factory_name |> build([]) |> insert!()
      end

      def insert!(schema) when is_struct(schema), do: schema |> @repo.insert!()
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def build(factory, _) when is_atom(factory),
        do: raise(ArgumentError, "The #{factory} is not defined")
    end
  end

  @spec uuid :: <<_::288>>
  def uuid(), do: Ecto.UUID.generate()

  @spec id :: integer
  def id(), do: System.unique_integer([:positive])

  if Code.ensure_loaded?(Shortcode) do
    @spec shortcode_uuid(nil | binary) :: binary
    def shortcode_uuid(prefix \\ nil), do: uuid() |> Shortcode.to_shortcode!(prefix)

    @spec shortcode_id(nil | binary) :: binary
    def shortcode_id(prefix \\ nil), do: id() |> Shortcode.to_shortcode!(prefix)
  end

  @spec utc_now :: DateTime.t()
  def utc_now(), do: DateTime.utc_now() |> DateTime.truncate(:second)

  @spec add(DateTime.t(), integer, System.time_unit()) :: DateTime.t()
  def add(%DateTime{} = datetime, amount_of_time, time_unit \\ :second) do
    datetime |> DateTime.add(amount_of_time, time_unit)
  end

  @spec params_for(struct) :: map
  def params_for(schema) when is_struct(schema) do
    schema
    |> AntlUtilsEcto.map_from_struct()
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end
end
