-- name: category_tree_by
-- docs: Gets all categories, its children and ancestors by input string.
WITH RECURSIVE tree AS (
  SELECT
    id,
    ARRAY[]::bigint[] AS category_ids,
    ARRAY[]::character varying[] AS category_names
  FROM
    categories
  WHERE parent_id IS NULL

  UNION ALL

  SELECT
    categories.id,
    tree.category_ids || categories.id,
    tree.category_names || categories.name
  FROM
    categories, tree
  WHERE
    categories.parent_id = tree.id
)

SELECT
  category_ids, category_names
FROM
  tree, unnest(category_names) name
WHERE
  name LIKE :search
