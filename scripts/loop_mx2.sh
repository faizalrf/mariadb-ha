#!/bin/bash
. ./.secrets
#
# Creates a table and starts inserting and reading values from it outside of a
# transaction with autocommit=1.
#
maxHost=172.20.0.6
mariadb -u ${UserName} -p${PassWord} -h${maxHost} -P4006 -e "CREATE DATABASE IF NOT EXISTS testdb; CREATE OR REPLACE TABLE testdb.tab (id serial, c1 varchar(100), ts timestamp(6));"

i=1
while [ $? -eq 0 ]
do
    echo "INSERT INTO testdb.tab(c1) VALUES (CONCAT('Data - ', ROUND(RAND() * 100000, 0)));"
    echo -e "SELECT concat('Executing SELECT on ', @@hostname, ' - MaxScale [${maxHost}] -> ID Retrieved:'), rpad(coalesce(id, ':(', id), 10, '.'), IF(COUNT(*)> 0, '\033[0;32mRecord Found\033[0m','\033[0;31m! Record Not Found !\033[0m' ) FROM testdb.tab WHERE id = $i;"
    i=$((i+1))
    sleep 0.05
done | mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P4006
