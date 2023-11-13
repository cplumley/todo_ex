defmodule TodoEx.TaskManager.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    belongs_to :user, TodoEx.Accounts.User
    has_many :tasks, TodoEx.TaskManager.Task

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name])
    |> assoc_constraint(:user)
  end
end
