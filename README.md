# MariaDB HA Setup

This will set up an MariaDB Enterprise server in a 3 MariaDB node + two MaxScale nodes setup.

Create a `.env` file with the following variables

```
DOWNLOAD_TOKEN=
MARIADB_VERSION=10.5
DEFAULT_PORT=3306
```

- `DOWNLOAD_TOKEN=<Your MariaDB Enterprise Download Token>`
  - This token can be retirevced from <https://mariadb.com/docs/deploy/token/>
- `MARIADB_VERSION=10.5`
  - Is hardcoded to 10.5, but feel free to change. 
  - There are some configurations that are dependant on 10.5 which you might have to remove if you plan to use an older version.
- `DEFAULT_PORT=3306`
  - Just the default MariaDB port, in case you need to use a different one.

Once the `.env` has been setup, execute the `./deploy` script to or execut ethe following steps manually to set the cluster up

```
docker-compose up --detach --build

docker container exec mariadb1 bash -c "mariadb < /tmp/init/01.sql"
docker container exec mariadb2 bash -c "mariadb < /tmp/init/02.sql"
docker container exec mariadb3 bash -c "mariadb < /tmp/init/02.sql"
```

The above will install 2 MaxScale 2.5 and 3 MariaDB 10.5 enterprise servers, set up replication between the nodes and set up MaxScale with some generic filters and firewall rules as examples.

Refer to the `./conf/max.cnf` for details on what is configured for MaxScale nodes. 

Destroy the environment by `docker-compose down`

