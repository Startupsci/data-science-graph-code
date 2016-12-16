// Create constraints will automatically create indexes
CREATE CONSTRAINT ON (d:Dataset)
ASSERT d.datasetName IS UNIQUE;
CREATE CONSTRAINT ON (ds:Datasource)
ASSERT ds.datasourceName IS UNIQUE;
CREATE CONSTRAINT ON (c:Category)
ASSERT c.categoryName IS UNIQUE;

// Create categories
LOAD CSV WITH HEADERS FROM "file:///categories.csv" AS sample
CREATE (c:Category)
SET c = sample;

// Create datasets
LOAD CSV WITH HEADERS FROM "file:///datasets.csv" AS sample
CREATE (d:Dataset)
SET d = sample;

// Create datasources
LOAD CSV WITH HEADERS FROM "file:///datasources.csv" AS sample
CREATE (ds:Datasource)
SET ds = sample;

// Match and return single label
MATCH (n:Dataset)
RETURN n
LIMIT 25

// Match and return multiple labels
MATCH (d:Dataset)
MATCH (ds:Datasource)
MATCH (c:Category)
RETURN d, ds, c
LIMIT 25

MATCH (n)
WHERE (n:Datasource) OR (n:Category) OR (n:Dataset)
RETURN n
LIMIT 25

// Create relationships
MATCH (d:Dataset)
MATCH (c:Category)
WHERE d.categoryName = c.categoryName
CREATE (c)-[:ORGANIZES]->(d);

// Review relationships
MATCH (c:Category)-[r:ORGANIZES]-(d:Dataset) RETURN c, Type(r), d;

// Review relationships
MATCH (c:Category)-[r:ORGANIZES]->(d:Dataset) RETURN c.categoryName, Type(r), Count(d) as datasets ORDER BY datasets DESC;

MATCH (ds:Datasource)
MATCH (c:Category)
WHERE ds.categoryName = c.categoryName
CREATE (c)-[:ORGANIZES]->(ds);

// Remove a categoryName properties once relationships are established
MATCH (ds:Datasource) REMOVE ds.categoryName;
MATCH (d:Dataset) REMOVE d.categoryName;

// Check existance of a property
MATCH (ds:Datasource) WHERE EXISTS (ds.tool)
RETURN ds.datasourceName, ds.tool;

// Profile a simulated execution of similar query to intended refactoring
PROFILE MATCH (ds:Datasource)
RETURN ds.datasourceName, Labels(ds);

// Add new label to existing nodes
MATCH (ds:Datasource) WHERE ds.tool="Data Catalog" SET ds:DataCatalog;
MATCH (ds:Datasource) WHERE ds.tool="Data API" SET ds:DataAPI;
MATCH (ds:Datasource) WHERE ds.tool="Data Explorer" SET ds:DataExplorer;
MATCH (ds:Datasource) WHERE ds.tool="Database Search" SET ds:DatabaseSearch;

// Remove a property from all nodes of a type
MATCH (ds:Datasource) REMOVE ds.tool;

// Add a label for all tools
MATCH (ds)
WHERE (ds:DataAPI) OR (ds:DataExplorer)
OR (ds:DataCatalog) OR (ds:DatabaseSearch)
SET ds:Tool;

// Match tool labels
MATCH (ds:Tool) RETURN ds.datasourceName, Labels(ds);

// Check if db contains Github datasource
MATCH (ds:Datasource)
WHERE ds.link CONTAINS 'github.com'
RETURN ds.datasourceName, ds.link;

// Create GitHub Datasource
CREATE (ds:Datasource:DataRepo:Tool
  { datasourceName: 'GitHub',
  about: 'GitHub Repository',
  link: 'https://github.com/'});

// Create new category for organizing GitHub
CREATE (c:Category {categoryName: 'Mixed'});

// Relate Mixed and GitHub
MATCH (c:Category {categoryName: 'Mixed'})
MATCH (ds:DataRepo)
CREATE (c)-[:ORGANIZES]->(ds);

// Check matching cloud property existance
MATCH (d:Dataset) WHERE EXISTS (d.cloud)
RETURN d.datasetName, d.cloud;

// Create Cloud datasets relationships
MATCH (d:Dataset)
MATCH (ds:Datasource)
WHERE ds.datasourceName=d.cloud
CREATE (ds)-[:STORES]->(d);

// Visualize the new relationship
MATCH (ds:Datasource)-[]-(d:Dataset) RETURN ds, d;

// Remove a property from all nodes of a type
MATCH (d:Dataset) REMOVE d.cloud;

// Create Awesome Public Datasets node
CREATE (ds:Datasource:DataList:Tool
  { datasourceName: 'Awesome Datasets',
  categoryName: 'Mixed',
  about: 'GitHub Awesome Public Datasets',
  link: 'https://github.com/caesar0301/awesome-public-datasets'});

// Related datasets to Awesome list
MATCH (d:Dataset)
MATCH (ds:Datasource)
WHERE ds.datasourceName='Awesome Datasets'
CREATE (ds)-[:LISTS]->(d);

// Relate categories
MATCH (ml:Category {categoryName: 'Machine Learning'})
MATCH (nlp:Category {categoryName: 'Natural Language'})
CREATE (nlp)-[:SUBSET_OF]->(ml);

// -------- REFERENCE ONLY ------------

// NOT REQUIRED IF CONSTRAIT CREATED: Create indexes
CREATE INDEX ON :Dataset(datasetName);
CREATE INDEX ON :Category(categoryName);
CREATE INDEX ON :Datasource(datasourceName);

// Create indexes
DROP INDEX ON :Dataset(datasetName);
DROP INDEX ON :Category(categoryName);
DROP INDEX ON :Datasource(datasourceName);

// Count of relationships
MATCH ()-[r]->()
RETURN count(r) AS relationships;

// Count of nodes
MATCH (n)
RETURN count(n) AS nodes;

// Count of relationships by dataset
MATCH (n:Dataset)-[r]-()
RETURN n.datasetName, count(r) as relationships
ORDER BY relationships DESC
LIMIT 25;

// Labels and relationships
MATCH (n)-[r]-()
RETURN DISTINCT labels(n), type(r);

// --- CAREFUL ---

// Renaming property keys
MATCH (d:Dataset)
WHERE d.storage IS NULL
SET d.storage = d.cloud
REMOVE d.cloud;

// Batch operations
MATCH (d:Dataset)
WHERE d.storage IS NULL
WITH d
LIMIT 100
SET d.storage = d.cloud
REMOVE d.cloud;


// Clear database of all nodes and relationships
MATCH (n)
OPTIONAL MATCH (n)-[r]-()
DELETE n,r;
