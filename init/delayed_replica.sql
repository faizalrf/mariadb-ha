STOP SLAVE;
-- Set nodes to have a delayed replication of 3 seconds
CHANGE MASTER TO MASTER_DELAY=3;
-- Start the Slave process
START SLAVE;