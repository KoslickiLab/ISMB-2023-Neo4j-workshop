# food-network
Welcome, ISMB Tutorial students!  This software project area contains code for
creating a Neo4j network of information about recipes and ingredients (see
[Credits](#credits)). To get started, jump to 
[Installation steps - Neo4j sandbox](#installation-steps---neo4j-sandbox).

# Credits
This graph database is based on the work of 
[Rik Van Bruggen](https://blog.bruggen.com/2013/12/fascinating-food-networks-in-neo4j.html) 
and
[Yong-Yeol Ahn](http://www.yongyeol.com).
Thanks also to Chris Plaisier and David Koslicki for help with Neo4j.

# Requirements
- Neo4j 5.5 or 5.7
- APOC 5.7
- Bash
- Cypher shell

# Installation steps - Neo4j sandbox

- In the Neo4j sandbox browser, run this Cypher command:

```
call apoc.cypher.runFile('https://raw.githubusercontent.com/ramseylab/food-network/main/make-food-database.cql');
```

which runs each Cypher statement in the file [`make-food-database.cql`](https://github.com/ramseylab/food-network/blob/main/make-food-database.cql), one at a time, through the Neo4j query processor. It will take 2-3 minutes to complete.

# Installation steps - local Neo4j database

- Install Neo4j Enterprise Edition version 5.7
- In `neo4j.conf`, set `dbms.memory.transaction.total.max=1024m`.
- Start the Neo4j server and set up an empty database with username `neo4j` and password `1337`.
- Install the APOC plug-in version 5.7
- Install Neo4j shell and make sure that `cypher-shell` is in your bash path
- In bash: `./run-make-food-database.sh`


