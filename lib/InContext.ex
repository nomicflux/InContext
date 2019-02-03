defmodule InContext do
  defmacro __using__(_) do
    quote do
      alias InContext.Graph, as: Graph
      alias InContext.Context, as: Context
      alias InContext.Search, as: Search
    end
  end
end
