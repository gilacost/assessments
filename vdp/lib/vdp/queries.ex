import AyeSQL, only: [defqueries: 3]

defqueries(Queries, "queries.sql", repo: Vdp.Repo)
