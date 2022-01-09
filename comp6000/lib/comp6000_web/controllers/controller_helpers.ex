defmodule Comp6000Web.Controllers.ControllerHelpers do
  import Ecto.Changeset

  def get_changeset_errors(changeset) do
    errors_map =
      traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    errors_map
    |> Map.keys()
    |> Enum.map(fn key -> "#{key} #{errors_map[key]}" end)
    |> Enum.join(",")
  end
end
