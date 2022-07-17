#!/bin/bash
. ./.secrets
#
# Creates a table and starts inserting and reading values from it outside of a
# transaction with autocommit=1.
#
# MaxScale port is configured as 4601

maxHost=127.0.0.1
Port=4601
DBName=testdb1
TableName=tab1

i=1
while [ $? -eq 0 ]
do
    echo -e "SELECT concat('SELECT FROM ${TableName} on ', @@hostname, ' - MaxPort [${Port}] ->'), rpad($i, 10, '.'), 
                IF(COUNT(*)> 0, '\033[0;32mRecord Found\033[0m','\033[0;31m! Not Found !\033[0m' ) 
            FROM ${DBName}.${TableName} WHERE id = $i;"
    sleep 0.04
done | mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P${Port}
