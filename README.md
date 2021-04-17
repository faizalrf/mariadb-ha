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

