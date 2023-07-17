#!/usr/bin/env bash
# Loads the Cypher statement file `make-food-database.cql` into Neo4j
# Stephen Ramsey, Oregon State University

cypher-shell -u neo4j -p 1337 < make-food-database.cql
