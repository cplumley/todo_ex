defmodule TodoEx.TaskManager.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :completed, :boolean, default: false
    field :description, :string
    field :title, :string
    belongs_to :project, TodoEx.TaskManager.Project

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :completed, :project_id])
    |> validate_required([:title, :description, :completed])
    |> assoc_constraint(:project)
  end
end
