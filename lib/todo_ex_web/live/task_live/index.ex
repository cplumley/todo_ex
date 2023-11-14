defmodule TodoExWeb.TaskLive.Index do
  use TodoExWeb, :live_view

  alias TodoEx.Accounts
  alias TodoEx.TaskManager.{Project, Task}
  alias TodoExWeb.Atoms
  alias TodoEx.Repo

  alias TodoEx.TaskManager

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(TodoEx.PubSub, "tasks")
    end

    socket =
      socket
      |> assign(users: Accounts.list_users() |> Enum.map(&{&1.name, &1.id}))

    {:ok, stream(socket, :projects, TaskManager.list_projects())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_project, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, TaskManager.get_project!(id))
  end

  defp apply_action(socket, :new_project, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :new_task, %{"id" => id}) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:project, TaskManager.get_project!(id))
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({TodoExWeb.TaskLive.ProjectFormComponent, {:saved, project}}, socket) do
    project = project |> Repo.preload([:user, :tasks])
    {:noreply, stream_insert(socket, :projects, project)}
  end

  def handle_info(%{task: task}, socket) do
    send_update(TodoExWeb.TaskLive.TaskComponent, id: task.project_id, task: task)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = TaskManager.get_project!(id)
    {:ok, _} = TaskManager.delete_project(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end
end
