//
// @Course: Systems Biology of Disease                           
// @Rscript: 4.1_cypher_queries.cql                              
// @Version: 1                                                   
// @Author: Brady Bernard and Chris Plaisier                     
// @Sponsored by:                                                
// Institute for Systems Biology                                 
// 1441 North 34th Street                                        
// Seattle, Washington  98103-8904                               
// (216) 732-2139                                                
//                                                               
// Copyright (C) 2015 by Institute for Systems Biology,          
// Seattle, Washington, USA.  All rights reserved.               
//                                                               
// This source code is distributed under the GNU Lesser          
// General Public License, the text of which is available at:    
//   http://www.gnu.org/copyleft/lesser.html                     
//

// Location of course Neo4j database:
// http://graffical.net
// Username:  neo4j
// Password:  1234

//
// Cancer miRNA Regulatory Network Queries 
//

// Which miRNAs are regulating a co-expression cluster?
MATCH (miRNA)-[:miRNA2cluster]->(cluster)
RETURN * LIMIT 15

// How many miRNA regulating a co-expression cluster relationships are in the database?
MATCH (miRNA)-[:miRNA2cluster]->(cluster)
RETURN count(*)

// Which miRNAs are regulating a co-expression cluster that modulates a hallmark of cancer?
MATCH (miRNA)-[:miRNA2cluster]->(cluster)-[:cluster2hallmark]->(hallmark)
RETURN * LIMIT 15

// Which miRNAs are regulating a co-expression cluster that modulates a hallmark of cancer?
MATCH (miRNA)-[:miRNA2cluster]->(cluster)-[:cluster2hallmark]->(hallmark)
RETURN count(*)

// Which miRNAs are regulating multiple co-expression clusters that modulate at least one hallmark of cancer? 
MATCH (miRNA)-[:miRNA2cluster]->(cluster1)-[:cluster2hallmark]->(hallmark)<-[:cluster2hallmark]-(cluster2)<-[:miRNA2cluster]-(miRNA)
RETURN count(*)

// Which miRNAs are regulating multiple co-expression clusters that modulate at least one hallmark of cancer?
MATCH (miRNA)-[:miRNA2cluster]->(cluster1)-[:cluster2hallmark]->(hallmark)<-[:cluster2hallmark]-(cluster2)<-[:miRNA2cluster]-(miRNA)
RETURN * LIMIT 25

// Which co-expression clusters are regulated by miR-29abc and that regulate the same hallmark?
MATCH (miRNA)-[:miRNA2cluster]->(cluster1)-[:cluster2hallmark]->(hallmark)<-[:cluster2hallmark]-(cluster2)<-[:miRNA2cluster]-(miRNA)
WHERE miRNA.name=~'miR-29a'
RETURN *


//
// Combining cancer miRNA regulatory network with drug repurposing
//

// Which miRNAs can be paired with KRAS mutation to induce synthetic lethality?
MATCH (mutation)-[:MUTSL]->(gene)<-[:cluster2gene]-(cluster)<-[:miRNA2cluster]-(miRNA), (cluster)-[:cluster2hallmark]->(hallmark)
WHERE mutation.name= 'KRAS'
RETURN *

// Which miRNAs can be paired with Tamoxifen to increase efficacy and reduce toxicity?
MATCH (miRNA)-[miRNA2cluster]->(cluster)-[cluster2gene]->(gene)<-[drug2gene]-(drug)
WHERE drug.name=~'Sorafenib'
RETURN *
