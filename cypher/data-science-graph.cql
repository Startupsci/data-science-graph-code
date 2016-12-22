// Database informtion: List Labels, Types, Keys
MATCH (n)-[r]->(m)
RETURN DISTINCT Labels(n), Type(r), Labels(m), Keys(m);

// Database information: count of nodes by Labels
MATCH (n)
RETURN DISTINCT Labels(n), Count(Labels(n));
