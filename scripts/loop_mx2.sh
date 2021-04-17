#!/bin/bash
. ./.secrets
#
# Creates a table and starts inserting and reading values from it outside of a
# transaction with autocommit=1.
#

mariadb -u ${UserName} -p${PassWord} -h172.20.0.6 -P4006 testdb -e "CREATE DATABASE IF NOT EXISTS testdb; CREATE OR REPLACE TABLE testdb.tab2(id int unsigned);"

i=1
while [ $? -eq 0 ]
do
    sleep 0.05
    echo "INSERT INTO testdb.tab2(id) VALUES ($i);"
    echo -e "SELECT @@hostname, id, IF(COUNT(*)> 0, '\033[0;32mFound\033[0m','\033[0;31m       Not Found\033[0m' ) FROM testdb.tab WHERE id = $i;"
    i=$((i+1))
done | mariadb -N -u ${UserName} -p${PassWord} -h172.20.0.6 -P4006 testdb
