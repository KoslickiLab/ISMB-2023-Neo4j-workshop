//
// @Course: ISMB Tutorial                           
// @Rscript: load_csv.cql                              
// @Version: 1                                                   
// @Author: Chris Plaisier                     
// @Sponsored by:                                                
// ASU, OSU, UPitt                                 
//                                                               
// This source code is distributed under the GNU Lesser          
// General Public License, the text of which is available at:    
//   http://www.gnu.org/copyleft/lesser.html                     
//

// miRNA->cluster
LOAD CSV FROM "https://drive.google.com/uc?export=download&id=1NtdOcuEakq-zpOel16JFofa1yhCuQt03" AS line
MERGE (m:miRNA {name: line[0]})
MERGE (c:cluster {name: line[2]})
MERGE (m)-[r:miRNA2cluster]-(c)

// cluster->gene
LOAD CSV FROM "https://drive.google.com/uc?export=download&id=1aL8lj5hzp9utg5V-1_ybbMN9fNvnLSZS" AS line
MERGE (c:cluster {name: line[0]})
MERGE (g:gene {name: line[2]})
MERGE (c)-[r:cluster2gene]-(g)

// cluster->hallmark
LOAD CSV FROM "https://drive.google.com/uc?export=download&id=1IsHRbxE4ITRKYahifG5TPB5teK-v9A7_" AS line
MERGE (c:cluster {name: line[0]})
MERGE (h:hallmark {name: line[2]})
MERGE (c)-[r:cluster2hallmark]-(h)

// drug->gene
LOAD CSV FROM "https://drive.google.com/uc?export=download&id=16zzIlzsrRdFPuwkYVptwOeZB_JFJptFC" AS line
MERGE (d:drug {name: line[0]})
MERGE (g:gene {name: line[2]})
MERGE (d)-[r:drug2gene]-(g)

