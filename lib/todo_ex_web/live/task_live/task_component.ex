defmodule TodoExWeb.TaskLive.TaskComponent do
  alias TodoEx.TaskManager
  alias TodoExWeb.Atoms
  use TodoExWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <div id={"incomplete-tasks-#{@project_id}"} phx-update="stream" class="flex flex-col gap-2">
        <div :for={{id, task} <- @streams.incomplete_tasks} id={id}>
          <.task_card task={task} myself={@myself} />
        </div>
      </div>
      <div id={"completed-tasks-#{@project_id}"} phx-update="stream" class="flex flex-col gap-2">
        <div :for={{id, task} <- @streams.completed_tasks} id={id}>
          <.task_card task={task} myself={@myself} />
        </div>
      </div>
    </div>
    """
  end

  def task_card(assigns) do
    ~H"""
    <Atoms.card horizontal={true} disabled={@task.completed}>
      <button phx-click={JS.push("toggle_completed", target: @myself, value: %{id: @task.id})}>
        <Atoms.todo_checkbox checked={@task.completed} />
      </button>
      <div>
        <p><%= @task.title %></p>
        <p class="text-xs"><%= @task.description %></p>
      </div>
    </Atoms.card>
    """
  end

  @impl true

  def update(%{task: %{completed: true} = task}, socket) do
    {:ok,
     stream_delete(socket, :incomplete_tasks, task)
     |> stream_insert(:completed_tasks, task)}
  end

  def update(%{task: %{completed: false} = task}, socket) do
    {:ok,
     stream_delete(socket, :completed_tasks, task)
     |> stream_insert(:incomplete_tasks, task)}
  end

  def update(%{project: project}, socket) do
    incomplete_tasks = Enum.filter(project.tasks, fn t -> not t.completed end)
    completed_tasks = Enum.filter(project.tasks, fn t -> t.completed end)

    {:ok,
     socket
     |> assign(project_id: project.id)
     |> stream(:incomplete_tasks, incomplete_tasks)
     |> stream(:completed_tasks, completed_tasks)}
  end

  @impl true
  def handle_event("toggle_completed", %{"id" => id}, socket) do
    task = TaskManager.get_task!(id)
    {:ok, _task} = TaskManager.toggle_completed(task)

    {:noreply, socket}
  end
end
