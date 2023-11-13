defmodule TodoEx.TaskManagerTest do
  use TodoEx.DataCase

  alias TodoEx.TaskManager

  describe "projects" do
    alias TodoEx.TaskManager.Project

    import TodoEx.TaskManagerFixtures
    import TodoEx.AccountsFixtures

    @invalid_attrs %{name: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert TaskManager.list_projects() == [project |> Repo.preload([:user, :tasks])]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert TaskManager.get_project!(project.id) == project |> Repo.preload(:user)
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{name: "some name", user_id: user_fixture().id}

      assert {:ok, %Project{} = project} = TaskManager.create_project(valid_attrs)
      assert project.name == "some name"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TaskManager.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Project{} = project} = TaskManager.update_project(project, update_attrs)
      assert project.name == "some updated name"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = TaskManager.update_project(project, @invalid_attrs)
      assert project |> Repo.preload(:user) == TaskManager.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = TaskManager.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> TaskManager.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = TaskManager.change_project(project)
    end
  end

  describe "tasks" do
    alias TodoEx.TaskManager.Task

    import TodoEx.TaskManagerFixtures

    @invalid_attrs %{completed: nil, description: nil, title: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert TaskManager.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert TaskManager.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{
        project_id: project_fixture().id,
        completed: true,
        description: "some description",
        title: "some title"
      }

      assert {:ok, %Task{} = task} = TaskManager.create_task(valid_attrs)
      assert task.completed == true
      assert task.description == "some description"
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TaskManager.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()

      update_attrs = %{
        completed: false,
        description: "some updated description",
        title: "some updated title"
      }

      assert {:ok, %Task{} = task} = TaskManager.update_task(task, update_attrs)
      assert task.completed == false
      assert task.description == "some updated description"
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = TaskManager.update_task(task, @invalid_attrs)
      assert task == TaskManager.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = TaskManager.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> TaskManager.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = TaskManager.change_task(task)
    end

    test "toggle_completed/1 updates task completion" do
      task = task_fixture(completed: true)
      assert {:ok, %{completed: false}} = TaskManager.toggle_completed(task)
    end
  end
end
