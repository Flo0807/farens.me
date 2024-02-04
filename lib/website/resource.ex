defmodule Website.Resource do
  @moduledoc """
  A behaviour for resources.
  """
  @callback path() :: binary()

  @callback init(map()) :: map()

  @callback compare(map(), map()) :: boolean()

  defmacro __using__(_) do
    quote do
      @behaviour Website.Resource

      def init(resource), do: resource

      def compare(_x, _y), do: false

      defoverridable init: 1, compare: 2
    end
  end
end
