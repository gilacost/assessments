defmodule Vdp do
  @moduledoc """
  TODO
  """

  @doc """
  Checks if the search is already in ets, if not calls
  `Queries.category_tree_by` which is a macro that through `AyeSQL` executes the
  raw query defined in `lib/vdp/queries.sql`.

  ## Example:
      iex> Queries.category_tree_by([search: "Au%"], run?: true)
      {:ok,
       [
         %{category_ids: [2, 3], category_names: ["Internal", "Authenticating"]},
         %{
           category_ids: [2, 3, 4],
           category_names: ["Internal", "Authenticating", "PINCode"]
         },
         %{
           category_ids: [2, 3, 5],
           category_names: ["Internal", "Authenticating", "Password"]
         },
         %{
           category_ids: [2, 3, 6],
           category_names: ["Internal", "Authenticating", "Secret Text"]
         }
       ]}

  Once this is return the tree is built using the get_in macro combined with the
  `Access.key` function that allows to dynamically access to keys and deaulting
  their value if they are not already created.

  The category id are built by zipping them with the names and then removing
  duplicates.
  """
  def build_category_tree(q) do
    case :ets.lookup(:searches_bucket, q) do
      [{^q, result}] ->
        result

      [] ->
        {:ok, results} = Queries.category_tree_by([search: q], run?: true)

        tree =
          results
          |> Enum.reduce(%{}, fn %{category_names: category_path}, acc ->
            case get_in(acc, Enum.map(category_path, &Access.key(&1, %{}))) do
              %{} ->
                put_in(acc, Enum.map(category_path, &Access.key(&1, %{})), %{})

              existing_category ->
                existing_category =
                  unless existing_category |> is_list,
                    do: [existing_category],
                    else: existing_category

                put_in(
                  acc,
                  Enum.map(category_path, &Access.key(&1, %{})),
                  [%{}] ++ existing_category
                )
            end
          end)

        ids =
          Enum.map(results, fn result ->
            Enum.zip(result.category_ids, result.category_names)
          end)
          |> List.flatten()
          |> Enum.map(fn {id, name} -> {name, id} end)
          |> Enum.into(%{})

        data = %{tree: tree, ids: ids}
        :ets.insert(:searches_bucket, {q, data})
        data
    end
  end
end
