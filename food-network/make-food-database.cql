// Creates a Neo4j database of recipes and their ingredients, from six
// character-separated-value (CSV) files
// Stephen Ramsey, Oregon State University

// drop all indexes
CALL apoc.schema.assert({},{},true) YIELD label, key RETURN *;

// drop all nodes and relationships
MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r;

// load all nodes in the file "1-basenodes.csv" (no labels assigned at this time)
// LOAD CSV WITH HEADERS FROM 'file:///1-basenodes.csv'
LOAD CSV WITH HEADERS FROM 'https://drive.google.com/uc?export=download&id=1J_b9CamwH5aRtgWd-qfrBZrDjZHYXg_3'
     AS row FIELDTERMINATOR ';'
     CREATE ({name: row.name, id: row.id, type: row.type});

// assign labels to all the nodes in the database, based on the temporary "type" property
MATCH (n) CALL apoc.create.addLabels(id(n), [n.type]) YIELD node
     REMOVE node.type; // RETURN node;

// load all nodes in the file "2-recipes.csv" (hard-code the labels to be "RECIPE")
// LOAD CSV WITH HEADERS FROM 'file:///2-recipes.csv'
LOAD CSV WITH HEADERS FROM 'https://drive.google.com/uc?export=download&id=1C94K8e9FZ-jiAx5zLwClwpsmSzCJnhpv'
     AS row FIELDTERMINATOR ';'
     CREATE (:RECIPE {id:row.id, source: row.source, cuisine: row.cuisine});

// create recipe sources
MATCH (n:RECIPE) 
     WITH DISTINCT n.source AS recipe_source
     CREATE (recipesource:RECIPE_SOURCE {name:recipe_source});

// create node property indexes
create index for (n:INGREDIENT_CATEGORY) on (n.name);
create index for (n:INGREDIENT) on (n.name);
create index for (n:INGREDIENT) on (n.id);
create index for (n:COMPOUND) on (n.name);
create index for (n:COMPOUND) on (n.id);
create index for (n:AREA) on (n.name);
create index for (n:CUISINE) on (n.name);
create index for (n:RECIPE) on (n.cuisine);
create index for (n:RECIPE) on (n.id);
create index for (n:RECIPE_SOURCE) on (n.name);

// link recipes to recipe sources
MATCH (n:RECIPE), (m:RECIPE_SOURCE)
     WHERE n.source=m.name
     WITH n as recipe, m AS source
     CREATE (source)-[:IS_SOURCE_OF]->(recipe);

// link recipes to cuisines
MATCH (cuisine:CUISINE), (recipe:RECIPE)
     WHERE recipe.cuisine = cuisine.name
     CREATE (recipe)-[:OF_CUISINE]->(cuisine);

// link ingredients to ingredient categories
// LOAD CSV WITH HEADERS FROM 'file:///3-ingred_belongsto_ingredcat.csv'
LOAD CSV WITH HEADERS FROM 'https://drive.google.com/uc?export=download&id=1b7cL_tX314xU7zl1aqeuEh47-BtK9h_v'
     AS row FIELDTERMINATOR ';'
     MATCH (ingred:INGREDIENT {name:row.ingredient_name}),
     (ingredcat:INGREDIENT_CATEGORY {name:row.ingredientcategory_name})
     CREATE (ingred)-[:BELONGS_TO]->(ingredcat);

// link COMPOUNDs to ingredients
// LOAD CSV WITH HEADERS FROM 'file:///4-ingred_has_compound.csv'
LOAD CSV WITH HEADERS FROM 'https://drive.google.com/uc?export=download&id=10FX7v-V7l3MagnXi74t0VgT7S_RCPKUZ'
     AS row FIELDTERMINATOR ';'
     MATCH (compound:COMPOUND {id:row.compound_id}), (ingred:INGREDIENT {id:row.ingredient_id})
     CREATE (compound)-[r:COMP_PART_OF]->(ingred);

// link cuisines to areas
// LOAD CSV WITH HEADERS FROM 'file:///5-cuisine_locatedin_area.csv'
LOAD CSV WITH HEADERS FROM 'https://drive.google.com/uc?export=download&id=1z1Jn-3wDidd1gRitcVOtvNgbUyWUNRFC'
     AS row FIELDTERMINATOR ';'
     MATCH (cuisine:CUISINE {name:row.cuisine_name}), (area:AREA {name:row.area_name})
     CREATE (cuisine)-[r:LOCATED_IN]->(area);

// link ingredients to recipes
// LOAD CSV WITH HEADERS FROM 'file:///6-ingred_partof_recipe.csv'
LOAD CSV WITH HEADERS FROM 'https://drive.google.com/uc?export=download&id=160eJTbNrP3uo2KFqHq4JEz5ZlG8w_B1A'
     AS row FIELDTERMINATOR ';'
     MATCH (ingred:INGREDIENT {name:row.ingredient_name}), (recipe:RECIPE {id:row.recipe_id})
     CREATE (ingred)-[r:INGR_PART_OF]->(recipe);

