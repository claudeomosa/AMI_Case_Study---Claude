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

  @doc """
  Marks the given todo as done and generates a new recommendation.
  """
  def check_and_update_recommendation(todo_id) do
    GenServer.cast(__MODULE__, {:check, todo_id})
  end

  @doc """
  Marks the given todo as not done and generates a new recommendation.
  """
  def uncheck_and_update_recommendation(todo_id) do
    GenServer.cast(__MODULE__, {:uncheck, todo_id})
  end

  @doc """
  Deletes the todo and generates a new recommendation if the deleted todo was the current recommendation.
  """
  def delete_and_update_recommendation(todo) do
    GenServer.cast(__MODULE__, {:delete, todo})
  end
  # Server Callbacks

  @impl true
  def init(_args) do
    recommendation = generate_recommendation()
    {:ok, %{recommendation: recommendation}}
  end

  @impl true
  def handle_call(:get_recommended_todo, _from, state) do
    case state.recommendation do
      0 -> {:reply, nil, state}
      _ ->
        {:reply, state.recommendation, state}
      end
  end

  @impl true
  def handle_cast({:check, todo_id}, _state) do
    Todos.check(todo_id)
    new_recommendation = generate_recommendation()
    {:noreply, %{recommendation: new_recommendation}}
  end

  @impl true
  def handle_cast({:uncheck, todo_id}, _state) do
    Todos.uncheck(todo_id)
    new_recommendation = generate_recommendation()
    {:noreply, %{recommendation: new_recommendation}}
  end

  @impl true
  def handle_cast({:delete, todo}, state) do
    {:ok, _todo} = Todos.delete_todo(todo)

    if state.recommendation == todo do
      new_recommendation = generate_recommendation()
      {:noreply, %{recommendation: new_recommendation}}
    else
      {:noreply, state}
    end
  end
  # Helper Functions

  defp generate_recommendation() do
    Todos.get_recommended()
  end
end
