defmodule TodoExWeb.Atoms do
  @moduledoc """
  Provides the Atom components for atomic design implementation

  These atoms are the building blocks of the site, components such as
  the headings, subheadings, titles, buttons, horizontal rule, and others
  belong in this folder. While atoms can be used at the page level, they
  are typically used to build higher level components in the design
  system.
  """

  use Phoenix.Component

  @doc """
  Renders a circular avatar with initials for user.

  A set of initials less than three, or a name, can
  be passed in to the initials argument. If a name
  is passed in, the first and last name given will
  be used to create the initials. If only a first name
  is given, the first letter will be used in the avatar

  ## Examples
      <.avatar initials="JD" />
      <.avatar initials="John Doe" />
      <.avatar initials="John" />
      <.avatar initials="John Smith Doe" />
  """
  attr :initials, :string, required: true

  def avatar(%{initials: initials} = assigns) when byte_size(initials) > 2 do
    truncated_initials = String.split(initials, " ") |> truncate_initials()

    assigns
    |> assign(initials: truncated_initials)
    |> avatar()
  end

  def avatar(assigns) do
    ~H"""
    <div class="relative inline-flex items-center justify-center w-10 h-10 overflow-hidden bg-gray-100 rounded-full dark:bg-gray-600">
      <span class="font-medium text-gray-600 dark:text-gray-300">
        <%= @initials %>
      </span>
    </div>
    """
  end

  defp truncate_initials(initials_list) when length(initials_list) > 1 do
    first_initial = initials_list |> hd() |> String.at(0)
    last_initial = initials_list |> Enum.reverse() |> hd() |> String.at(0)
    "#{first_initial}#{last_initial}"
  end

  defp truncate_initials([name]), do: name |> String.at(0)

  @doc """
  Renders a button around text

  ## Examples
      <.button variant="primary">Add Project</button>
      <.button variant="icon" phx-click={show_modal("edit_task")}>
        <.icon name="hero-pencil-square" class="h-5 w-5 bg-white" />
      </.button>
  """
  attr :variant, :string, values: ~w(primary secondary outline icon)
  attr :class, :string, default: nil
  attr :type, :string, values: ~w(button submit reset) ++ [nil], default: nil
  attr :rest, :global, doc: "The phx-click and data elements for the button action"

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        @class,
        "transition",
        @variant == "primary" &&
          "border bg-blue-500 rounded-md p-2 text-white text-xs hover:bg-blue-600",
        @variant == "secondary" &&
          "border bg-purple-500 rounded-md p-2 text-white text-xs hover:bg-purple-600",
        @variant == "outline" &&
          "border border-green-600 rounded-md p-2 text-green-600 text-xs hover:text-white hover:bg-green-600",
        @variant == "icon" &&
          "flex items-center relative p-2 hover:bg-gray-100 dark:hover:bg-zinc-700 focus:bg-gray-100 dark:focus:bg-zinc-600 focus:ring-4 focus:ring-blue-200 dark:focus:ring-blue-700 rounded-full transition"
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :loading, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :horizontal, :boolean, default: false
  attr :rest, :global

  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div
      class={[
        "flex p-4 border border-gray-200 rounded-lg gap-4",
        if(@horizontal, do: "items-center", else: "flex-col"),
        @disabled &&
          "line-through bg-gray-100 border-gray-100 dark:bg-zinc-700 text-gray-500 dark:border-zinc-700"
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
