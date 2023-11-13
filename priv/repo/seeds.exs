# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TodoEx.Repo.insert!(%TodoEx.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

TodoEx.Accounts.create_user(%{name: "John Doe", email: "john_doe@mail.com"})
TodoEx.Accounts.create_user(%{name: "Timothy Von Sweet", email: "tim_v_sweet@mail.com"})
