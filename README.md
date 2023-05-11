# MariaDB HA Setup

## Assumptions

- `docker compose` 
- `Docker`
- Should work on MacOS/Windows & Linux running the above versions
- `MariaDB-client` is installed on the machine where this `docker compose` is going to run
- There might be some networking related issues when running this on Windows, but it should work fine on MacOS / Linux distros

## The Setup

This will set up a MariaDB Enterprise server in a 3 MariaDB node + two MaxScale nodes setup.
 
Create a `.env` file under `mariadb-ha` folder (which contains `docker-compose.yml` file), with the following values
 
```
DOWNLOAD_TOKEN=<MariaDB-Token>
MRDB_VER=10.6
MAXSCALE_VER=23.01
TARGETARCH=amd64
```
 
***Note:** All the `docker-compose` commands needs to be executed from within the `mariadb-ha` folder, while the other scripts can be executed from anywhere.*
 
- `DOWNLOAD_TOKEN=<Your MariaDB Enterprise Download Token>`
  - This token can be retrieved from <https://mariadb.com/docs/deploy/token/> but you must have an a MariaDB enterprise account.
- `MARIADB_VERSION=10.6`
  - Is hardcoded to 10.6, but feel free to change.
  - There are some configurations that are dependant on 10.6 which you might have to remove if you plan to use an older version.
- `MAXSCALE_VER=23.01`
  - MaxScale Version to use

Once the `.env` has been created, execute the `./deploy` script or execute the following steps manually to set the cluster up
 
```
docker-compose up --detach --build
 
docker container exec mariadb1 bash -c "mariadb < /tmp/init/01.sql"
docker container exec mariadb2 bash -c "mariadb < /tmp/init/02.sql"
docker container exec mariadb3 bash -c "mariadb < /tmp/init/02.sql"
```
 
## What will be done
 
This will be using CentOS 8 containers and will:
 
- Install 2 MaxScale 23.01 nodes with static IP
- Install 3 MariaDB 10.5 enterprise servers nodes with static IP
- Set up semi-synchronous replication between the MariaDB nodes
- Set up MaxScale with some generic filters and firewall rules as examples
- Enable Transaction replay and Causal Reads for MaxScale
- Enable Cooperative Monitoring
  - `majority_of_all`
  - `majority_of_running`
- Enable MaxScale GUI
  - To Access GUI, on the browser, go to the following URLs, the user/password are `admin`/`mariadb`
    -  <http://172.20.0.5:8989> for MaxScale #1 GUI
    -  <http://172.20.0.6:8989> for MaxScale #2 GUI
 
## Connect to the Containers
 
To connect to the individual containers we can:
 
- MaxScale1: `docker contaienr exec -it max1 bash`
- MaxScale2: `docker contaienr exec -it max2 bash`
- MariaDB1: `docker contaienr exec -it mariadb1 bash`
- MariaDB2: `docker contaienr exec -it mariadb2 bash`
- MariaDB3: `docker contaienr exec -it mariadb3 bash`
 
### User Accounts
 
Following script is executed at the time the docker-compose is setting up the environment
 
```sql
CREATE USER  IF NOT EXISTS repl_user@'%' identified by 'P@ssw0rd';
GRANT ALL ON *.* to repl_user@'%';
 
CREATE USER IF NOT EXISTS app_user@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO app_user@'%';
 
CREATE USER IF NOT EXISTS maxuser@'%' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL ON *.* TO maxuser@'%';
```
 
***Note:** `GRANT ALL` is given just to keep the setup simple as it's only for testing, consider proper privileges for replication and maxscale user, etc. *
 
If we want to connect to the MariaDB services through an external MariaDB client which is installed on your laptop, for instance, we can simply do the following
 
- To Connect to MaxScale MariaDB Service, take note of the MaxScale IP and its Read/Write service port `4006`
 
  ```
  $ mariadb -uapp_user -p -h172.20.0.5 -P4006
  ```
 
- To Connect to one of the MariaDB Service, take note of the MariaDB server IP and its default port `3306`
 
  ```
  $ mariadb -uapp_user -p -h172.20.0.2 -P3306
  ```
 
***Note:** The IP addresses can be retrieved from the `docker-compose.yml` file.*
 
There is a four of scripts under `/scripts`
- `./scripts/loop_mx1.sh`
  - Simulates reads and writes using the same connection on MaxScale 1
- `./scripts/loop_global_mx1.sh`
  - Simulates reads and writes using different connections on MaxScale 1
- `./scripts/loop_mx2.sh`
  - Simulates reads and writes using the same connection on MaxScale 1
- `./scripts/loop_global_mx2.sh`
  - Simulates reads and writes using different connection on MaxScale 1

which can be used to push some transactions to the MariaDB through the MaxScale1 and MaxScale 2 respectively. These are super useful for testing the behavior of Read/Write splitting service and how Causal reads can provide a consistent reading behavior and how Transaction Replay improves high availability when MariaDB nodes go down. Furthermore, the cooperative monitoring parameters can help simplify running Two MaxScale without worrying about which of these MaxScale nodes will take care of MariaDB automatic failover/rejoin.

One great feature of MaxScale is, while it can do this automatically, but there might be a need to manually do a switchover. To switchover Primary node from `MariaDB-2` to `MariaDB-1` node, we can execute the `maxctrl` `switchover` command as follows from within the MaxScale node.

```
[root@max1 /]# maxctrl list servers
┌───────────┬────────────┬──────┬─────────────┬─────────────────┬──────────────┐
│ Server    │ Address    │ Port │ Connections │ State           │ GTID         │
├───────────┼────────────┼──────┼─────────────┼─────────────────┼──────────────┤
│ MariaDB-1 │ 172.20.0.2 │ 3306 │ 0           │ Slave, Running  │ 1-3000-23912 │
├───────────┼────────────┼──────┼─────────────┼─────────────────┼──────────────┤
│ MariaDB-2 │ 172.20.0.3 │ 3306 │ 1           │ Master, Running │ 1-2000-43006 │
├───────────┼────────────┼──────┼─────────────┼─────────────────┼──────────────┤
│ MariaDB-3 │ 172.20.0.4 │ 3306 │ 0           │ Slave, Running  │ 1-1000-42507 │
└───────────┴────────────┴──────┴─────────────┴─────────────────┴──────────────┘

[root@max1 /]# maxctrl call command mariadbmon switchover -t9999 MariaDB-Monitor MariaDB-1 MariaDB-2
OK

[root@max1 /]# maxctrl list servers
┌───────────┬────────────┬──────┬─────────────┬─────────────────┬──────────────┐
│ Server    │ Address    │ Port │ Connections │ State           │ GTID         │
├───────────┼────────────┼──────┼─────────────┼─────────────────┼──────────────┤
│ MariaDB-1 │ 172.20.0.2 │ 3306 │ 1           │ Master, Running │ 1-1000-45818 │
├───────────┼────────────┼──────┼─────────────┼─────────────────┼──────────────┤
│ MariaDB-2 │ 172.20.0.3 │ 3306 │ 0           │ Slave, Running  │ 1-1000-42507 │
├───────────┼────────────┼──────┼─────────────┼─────────────────┼──────────────┤
│ MariaDB-3 │ 172.20.0.4 │ 3306 │ 1           │ Slave, Running  │ 1-2000-44545 │
└───────────┴────────────┴──────┴─────────────┴─────────────────┴──────────────┘
```
 
Refer to the `./conf` folder (`max.cnf`, `mariadb1.cnf`, `mariadb2.cnf`, and `mariadb3.cnf`), for details on what is configured for all the nodes.
 
Destroy the environment by simply going to the `mariadb-ha` folder and executing `docker-compose down`

## Using MariaDB Community Version

If you want to use the MariaDB community version instead of the enterprise version, you will have to 

- Modify the `docker-compose.yml` file by removing the following block from all the three server nodes

```
        build:
            context: .
            args:
                SERVER_VERSION: ${MARIADB_VERSION}
                ES_TOKEN: ${DOWNLOAD_TOKEN}
                PORT: ${DEFAULT_PORT}
```

- Change the `image: mariadb-es` to `image: mariadb/server`
- Remove/Comment the `shutdown_wait_for_slaves=ON` argument in all of the `mariadb1.cnf`, `mariadb1.cnf`, and `mariadb1.cnf` files.
  - This particular configuration improves the stability and durability of the replication setup and is only available in the Enterprise version of the MariaDB server.

Deploy as per normal using the `./deploy` script from within the `mariadb-ha` folder.

## Thank you!

