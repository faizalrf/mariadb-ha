#!/bin/bash
. ./.secrets
#
# Creates a table and starts inserting and reading values from it outside of a
# transaction with autocommit=1.
#
Port=4602
maxHost=127.0.0.1
mariadb -u ${UserName} -p${PassWord} -h${maxHost} -P${Port} -e "CREATE DATABASE IF NOT EXISTS testdb; CREATE OR REPLACE TABLE testdb.tab2 (id serial, c1 varchar(100), ts timestamp(6));"

i=1
while [ $? -eq 0 ]
do
    echo "INSERT INTO testdb.tab2(c1) VALUES (CONCAT('Data - ', ROUND(RAND() * 100000, 0)));"
    echo -e "SELECT concat('Executing SELECT on ', @@hostname, ' - MaxScale [${maxHost}] -> ID Retrieved:'), rpad(coalesce(id, ':(', id), 10, '.'), 
                IF(COUNT(*)> 0, '\033[0;32mRecord Found\033[0m','\033[0;31m! Record Not Found !\033[0m' ) 
            FROM testdb.tab2 WHERE id = $i;"
    i=$((i+1))
    sleep 0.05
done | mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P${Port}
