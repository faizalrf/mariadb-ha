#!/bin/bash
. ./.secrets
#
# Creates a table and starts inserting and reading values from it outside of a
# transaction with autocommit=1.
#
# MaxScale port is configured as 4602

maxHost=127.0.0.1
Port=4602
TableName=tab2

mariadb -u ${UserName} -p${PassWord} -h${maxHost} -P${Port} -e "DROP DATABASE IF EXISTS testdb; CREATE DATABASE IF NOT EXISTS testdb; CREATE TABLE IF NOT EXISTS testdb.${TableName} (id serial, c1 varchar(100), ts timestamp(6));"

i=1
while [ $? -eq 0 ]
do
    echo "INSERT INTO testdb.${TableName}(c1) VALUES (CONCAT('Data - ', ROUND(RAND() * 100000, 0)));"
    echo "UPDATE testdb.${TableName} SET c1 = CONCAT('Data - ', ROUND(RAND() * 100000, 0)) LIMIT 1;"
    echo -e "SELECT concat('SELECT FROM ${TableName} on ', @@hostname, ' - MaxPort [${Port}] ->'), rpad($i, 10, '.'), 
                IF(COUNT(*)> 0, '\033[0;32mRecord Found\033[0m','\033[0;31m! Not Found !\033[0m' ) 
            FROM testdb.${TableName} WHERE id = $i;"
    i=$((i+1))
    sleep 0.04
done | mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P${Port}
