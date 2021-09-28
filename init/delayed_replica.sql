STOP SLAVE;
-- Set nodes to start replicaiton from `mariadb1` node
CHANGE MASTER TO MASTER_DELAY=3;
-- Start the Slave process
START SLAVE;