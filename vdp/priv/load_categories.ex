alias Vdp.{Repo, Category}

Repo.delete_all(Category)

File.stream!("priv/pairs.csv")
|> CSV.decode!()
|> Enum.slice(1..-1)
|> Enum.map(fn [parent, child] ->
  parent = String.trim(parent)
  child = String.trim(child)

  id =
    case Category.last_inserted_by(:name, parent) do
      nil ->
        %Category{id: id} = Repo.insert!(%Category{name: parent})
        id

      %Category{id: id} ->
        id
    end

  %Category{name: child, parent_id: id} |> Repo.insert!()
end)
