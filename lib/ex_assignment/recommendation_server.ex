defmodule ExAssignment.RecommendationServer do
  use GenServer

  alias ExAssignment.Todos

  # Client API

  @doc """
  Starts the GenServer.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Gets the current recommended todo.
  """
  def get_recommended_todo() do
    GenServer.call(__MODULE__, :get_recommended_todo)
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    recommendation = generate_recommendation()
    {:ok, %{recommendation: recommendation}}
  end

  @impl true
  def handle_call(:get_recommended_todo, _from, state) do
    IO.inspect(state.recommendation, label: "Recommendation")
    {:reply, state.recommendation, state}
  end

  # Helper Functions

  defp generate_recommendation() do
    Todos.get_recommended()
  end
end
