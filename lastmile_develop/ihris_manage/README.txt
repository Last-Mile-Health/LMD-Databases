
-- SQL views for setting up federated tables betweeen the LMD MySQL Server running on godaddy VPS and the ihris manager MySQL Server running on aws.

-- On ihris MySQL instance put the views to be made availabe for remote querying.  On LMD MySQL instance, create federated tables that point to the remote views.

-- Note: Tthere is no such thing as a federated view, but a federated table can point to a remote view. 