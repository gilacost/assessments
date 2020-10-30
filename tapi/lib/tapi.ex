defmodule Tapi do
  @moduledoc """
  Tapi defines useful shared logic related to the business
  context.

  ## Using the module

  If you use this module in another module that has
  a data attribute registered, you will be able to call
  `Module.list` and get the data.

  ## Examples:

      defmodule MyModule do
        use Tapi, :data
        @data ["my data"]
      end

      iex> MyModule.list()
      ["my data"]

  """

  @doc false
  defmacro __using__(:data) do
    quote location: :keep do
      @before_compile Tapi
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    data = Module.get_attribute(env.module, :data)

    if data == nil do
      raise "no data set in module #{inspect(env.module)}"
    end

    quote do
      @spec list() :: [String.t()]
      def list(), do: unquote(data)
    end
  end
end
