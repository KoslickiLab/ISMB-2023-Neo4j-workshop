// Example Cypher commands for querying the Food Network
// Stephen Ramsey, Oregon State University

// Slide 29: Set up the database:
CALL apoc.cypher.runFile('https://raw.githubusercontent.com/ramseylab/food-network/main/make-food-database.cql');

// Slide 41: Return the first 25 nodes of type `AREA`
MATCH (n:AREA)
RETURN n
LIMIT 25;

// Slide 42: Count the `INGREDIENT` nodes
MATCH (n:INGREDIENT)
RETURN count(*);

// Slide 43: Examine a few `INGREDIENT` nodes
MATCH (n:INGREDIENT)
RETURN n
LIMIT 3;

// Slide 44: How many `INGREDIENT` nodes contain the word "apple"?
MATCH (n:INGREDIENT)
WHERE n.name CONTAINS 'apple’
RETURN n;

// Slide 45: Display the meta-graph of the food network
CALL apoc.meta.graph()

// Slide 46: Count the numbers of each type of node
MATCH (n)
RETURN DISTINCT HEAD(LABELS(n)), COUNT(*) AS c
ORDER BY c DESC;

// Slide 47: How many (INGREDIENT, RECIPE) pairs connected by INGR_PART_OF, are there?
MATCH (n:INGREDIENT)-[r:INGR_PART_OF]->(m:RECIPE)
RETURN COUNT(*);

// Slide 48: List the first few recipe `id` numbers
MATCH (n:RECIPE)
RETURN n.id
LIMIT 3;

// Slide 49: What is the cuisine of the recipe with id 1000000?
MATCH (n:RECIPE {id: '1000000'})-[r:OF_CUISINE]->(m)
RETURN m;

// Slide 50: What is the shopping list to make recipe 1000000?
MATCH (n:INGREDIENT)-[r:INGR_PART_OF]->(m:RECIPE {id: '1000000'})
RETURN DISTINCT n.name;

// Slide 51: What are the most commonly used ingredients?
MATCH (n:INGREDIENT)-[r:INGR_PART_OF]->(m:RECIPE)
RETURN DISTINCT n.name, count(*) AS c
ORDER BY c DESC;

// Slide 52: What are the most common ingredients in recipes marked as “Vietnamese” cuisine?
MATCH (n:INGREDIENT)-[r:INGR_PART_OF]->(m:RECIPE)-[s:OF_CUISINE]->(v:CUISINE {name: "Vietnamese"})
RETURN DISTINCT n.name, count(*) as c
ORDER BY c DESC;

// Slide 53: How many recipes are there, by cuisine type?
MATCH (n)-[r:OF_CUISINE]->(m)
RETURN DISTINCT m.name, COUNT(*) AS c
ORDER BY c DESC;

// Slide 54: What node has highest degree in the graph?
MATCH (n)-[r]->(m)
RETURN DISTINCT n.name, n.id, head(labels(n)), count(*) as c
ORDER BY c DESC;

// Slide 55: Want to find out what Neo4j version it is, using Cypher?
CALL dbms.components()

// Slide 56: View your memory usage
:sysinfo

// Slide 58:  How many recipes are there, by source?
match (s:RECIPE_SOURCE)-[p:IS_SOURCE_OF]->(r:RECIPE) 
return distinct s.name, count(*) as c order by c desc;

// Slide 59: How many recipes are there, by region?
match (n:RECIPE)-[r:OF_CUISINE]-(m:CUISINE)-[s:LOCATED_IN]->(p:AREA) 
return distinct p.name, count(*) as c 
order by c desc;
