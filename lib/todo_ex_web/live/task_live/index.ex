defmodule TodoExWeb.TaskLive.Index do
  use TodoExWeb, :live_view

  alias TodoEx.Accounts
  alias TodoEx.TaskManager.Project
  alias TodoExWeb.Atoms
  alias TodoEx.Repo

  alias TodoEx.TaskManager

  @impl true
  def mount(_params, _session, socket) do
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
    IO.inspect(socket.assigns.streams, label: "New Project")

    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    IO.inspect(socket.assigns.streams, label: "Index")

    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({TodoExWeb.TaskLive.FormComponent, {:saved, project}}, socket) do
    {:noreply, stream_insert(socket, :projects, project |> Repo.preload(:user))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = TaskManager.get_project!(id)
    {:ok, _} = TaskManager.delete_project(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end
end
