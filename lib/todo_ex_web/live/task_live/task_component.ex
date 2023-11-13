defmodule TodoExWeb.TaskLive.TaskComponent do
  alias TodoEx.TaskManager
  alias TodoExWeb.Atoms
  use TodoExWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={"tasks-#{@project_id}"} phx-update="stream" class="flex flex-col gap-2">
      <div :for={{id, task} <- @streams.tasks} id={id}>
        <Atoms.card horizontal={true} disabled={task.completed}>
          <button phx-click={JS.push("toggle_completed", target: @myself, value: %{id: task.id})}>
            <Atoms.todo_checkbox checked={task.completed} />
          </button>
          <div>
            <p><%= task.title %></p>
            <p class="text-xs"><%= task.description %></p>
          </div>
        </Atoms.card>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{task: task}, socket) do
    {:ok, stream_insert(socket, :tasks, task)}
  end

  def update(%{project: project}, socket) do
    {:ok,
     socket
     |> assign(project_id: project.id)
     |> stream(:tasks, project.tasks)}
  end

  @impl true
  def handle_event("toggle_completed", %{"id" => id}, socket) do
    task = TaskManager.get_task!(id)
    {:ok, _task} = TaskManager.toggle_completed(task)

    {:noreply, socket}
  end

  def handle_info(%{task: task}, socket) do
    send_update(TodoExWeb.TaskLive.TaskComponent, id: task.project_id, task: task)
    {:noreply, socket}
  end
end
