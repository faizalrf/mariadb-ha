-- Stop Slave in case it's still running and reset all binlogs / replication slave status
STOP SLAVE; RESET MASTER; RESET SLAVE; RESET SLAVE ALL;

-- reset current replicaiton position so that replica nodes can start fresh
SET GLOBAL GTID_SLAVE_POS='';

-- Set nodes to start replicaiton from `mariadb1` node
CHANGE MASTER TO MASTER_HOST='mariadb1', MASTER_USER='repl_user', MASTER_PASSWORD='P@ssw0rd', MASTER_PORT=3306, MASTER_USE_GTID=slave_pos;

-- Start the Slave process
START SLAVE;