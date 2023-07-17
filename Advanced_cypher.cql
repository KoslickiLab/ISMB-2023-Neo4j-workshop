// Load the graph data
LOAD CSV FROM "https://drive.google.com/uc?export=download&id=1NtdOcuEakq-zpOel16JFofa1yhCuQt03" AS line
MERGE (m:miRNA {name: line[0]})
MERGE (c:cluster {name: line[2]})
MERGE (m)-[r:miRNA2cluster]-(c)

LOAD CSV FROM "https://drive.google.com/uc?export=download&id=1aL8lj5hzp9utg5V-1_ybbMN9fNvnLSZS" AS line
MERGE (c:cluster {name: line[0]})
MERGE (g:gene {name: line[2]})
MERGE (c)-[r:cluster2gene]-(g)

LOAD CSV FROM "https://drive.google.com/uc?export=download&id=1IsHRbxE4ITRKYahifG5TPB5teK-v9A7_" AS line
MERGE (c:cluster {name: line[0]})
MERGE (h:hallmark {name: line[2]})
MERGE (c)-[r:cluster2hallmark]-(h)

LOAD CSV FROM "https://drive.google.com/uc?export=download&id=16zzIlzsrRdFPuwkYVptwOeZB_JFJptFC" AS line
MERGE (d:drug {name: line[0]})
MERGE (g:gene {name: line[2]})
MERGE (d)-[r:drug2gene]-(g)

// Look at 5 nodes of degree 2
MATCH (n) WHERE apoc.node.degree(n)=2 RETURN n LIMIT 5

// Look at all neighbors of degree 16 nodes
MATCH (n)-[]-(m)
WHERE apoc.node.degree(n)=16 
WITH n.name AS degree16Node, collect(m.name) AS neighbors
RETURN degree16Node, size(neighbors), neighbors

// Look at drug targets for a list of drugs
UNWIND ['Lepirudin', 'Cetuximab', 'Denileukin diftitox', 'Etanercept', 'Bivalirudin', 'Leuprolide', 'Peginterferon alfa-2a', 'Alteplase', 'Sermorelin', 'Interferon alfa-n1'] as drugName
MATCH (n:drug)-[]-(g:gene)
WHERE n.name=drugName
WITH drugName, collect(g.name) as targets
RETURN drugName, targets

// Look at the schema of this graph
call apoc.meta.graph() 
yield nodes, relationships

// Load an in-memory "projection" of the subgraph consisting of all drugs and genes
CALL gds.graph.project(
    'drugGene',
    ['drug','gene'],
    'drug2gene'
)
YIELD graphName, nodeProjection, nodeCount, relationshipProjection, relationshipCount

// Load an in-memory projection of the entire graph
CALL gds.graph.project(
    'all',
    '*',
    '*'
)
YIELD graphName, nodeProjection, nodeCount, relationshipProjection, relationshipCount

// Compute the page rank of all nodes and return them
CALL gds.pageRank.stream('all')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score AS pageRank
RETURN n.name AS name, labels(n) AS label, pageRank
ORDER BY pageRank DESC, name ASC

// Write the page rank values to the drug-gene graph projection
CALL gds.pageRank.write('drugGene',
    {
        writeProperty: 'pageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations

// verify that the page rank values were written to the nodes
match (n:gene)
return n.name as name , n.pageRank as pageRank
ORDER BY n.pageRank DESC, n.name ASC

// Compute clusters using the Louvain algorithm on the drug-gene graph projection
CALL gds.louvain.stream('drugGene')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS n, communityId
RETURN
    communityId,
    SIZE(COLLECT(n)) AS numberOfEntities,
    COLLECT(DISTINCT n.name) AS entities
ORDER BY numberOfEntities DESC, communityId;

// Take a look at one of these clusters
WITH ["Fingolimod", "S1PR5", "S1PR1", "S1PR3", "Ponesimod", "Ozanimod"] AS namesList
MATCH (n)--(m)
WHERE ANY(name IN n.name WHERE name IN namesList) AND ANY(name IN m.name WHERE name IN namesList)
RETURN n

// compute the number of weakly connected components in the drug-gene graph projection
CALL gds.wcc.stream('drugGene')
YIELD nodeId, componentId
RETURN count(DISTINCT componentId) AS componentCount

// also list the size of each of the weakly connected components
CALL gds.wcc.stream('drugGene')
YIELD nodeId, componentId
WITH componentId, count(nodeId) AS componentSize
RETURN componentId, componentSize
ORDER BY componentSize DESC

// write the cluster index on each node corresponding to which cluster the node belongs to
CALL gds.wcc.write('drugGene',{writeProperty: "component_index"})

// compute the Jaccard similarity between nodes
CALL gds.nodeSimilarity.stream(
    'drugGene',
    {
        topK: 1, //for each node, get the most similar other node
        topN: 10,  //only do this for 10 total nodes
        degreeCutoff: 10  // only look at nodes with degree >=10
    }
)
YIELD node1, node2, similarity
WITH gds.util.asNode(node1) AS n1, gds.util.asNode(node2) AS n2, similarity AS similarityScore
RETURN
    n1.name AS name,
    n2.name AS similarEntity,
    similarityScore
ORDER BY similarityScore DESC

// Visualize the Jaccard similarity
CALL gds.nodeSimilarity.stream('drugGene',
    {
        topK: 1, //for each node, get the most similar other node
        topN: 10,  //only do this for 10 total nodes
        degreeCutoff: 10  // only look at nodes with degree >=10
    })
YIELD node1, node2, similarity
WITH gds.util.asNode(node1) AS n1, gds.util.asNode(node2) AS n2, similarity AS similarityScore
RETURN
n1, n2

// Perform a random projection into dimension 4 for the "all" graph projection
CALL gds.fastRP.mutate('all',
  {
    embeddingDimension: 4,
    randomSeed: 42,
    mutateProperty: 'embedding',
    iterationWeights: [0.8, 1, 1, 1]
  }
)
YIELD nodePropertiesWritten

// write these as node properties
CALL gds.fastRP.write('all',
  {
    embeddingDimension: 4,
    randomSeed: 42,
    writeProperty: 'embedding',
    iterationWeights: [0.8, 1, 1, 1]
  }
)
YIELD nodePropertiesWritten

// Use the K-nearest neighbors algorithm to quantify similarity between nodes, and add edges indicating this with a score of similarity as edge properties
CALL gds.knn.write('all', {
    topK: 2,
    nodeProperties: ['embedding'],
    randomSeed: 42,
    concurrency: 1,
    sampleRate: 1.0,
    deltaThreshold: 0.0,
    writeRelationshipType:'SIMILAR',
    writeProperty: 'score'
})
YIELD nodesCompared, relationshipsWritten, similarityDistribution
RETURN nodesCompared, relationshipsWritten, similarityDistribution.mean as meanSimilarity

// Find highly similar clusters
match (n1:cluster)-[r:SIMILAR]-(n2:cluster)
return n1.name, n2.name, r.score as similarity order by similarity desc limit 10

// Take a look at a pair of clusters
match (n:cluster) 
where n.name in ['MPM_Mesothelioma_Gordon_5', 'GCT_Seminoma_Korkola_4'] 
return n

// Find highly similar clusters, find neighbors that are in one of the clusters but not the other, then return this "recommendation" along with what cluster you are recommending be expanded 
match (n1:cluster)-[r:SIMILAR]-(n2:cluster)
where r.score>0.99
with n1, n2
match (n1)-[r]-(neighbor)
where type(r)<>'SIMILAR' and not (neighbor)--(n2)
with n1, n2, neighbor
optional match  (n2)-[r]-(neighbor2)
where type(r)<>'SIMILAR' and not (neighbor2)--(n1)
return n1.name as n1, collect(distinct neighbor.name) as n1Suggestions, n2.name as n2, collect(distinct neighbor2.name) as n2Suggestions order by size(n1Suggestions)+size(n2Suggestions) asc limit 10
