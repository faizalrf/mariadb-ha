#!/bin/bash
. ./.secrets
#
# Creates a table and starts inserting and reading values from it outside of a
# transaction with autocommit=1.
#
maxHost=172.20.0.5
mariadb -u ${UserName} -p${PassWord} -h${maxHost} -P4006 -e "CREATE DATABASE IF NOT EXISTS testdb; CREATE OR REPLACE TABLE testdb.tab (id serial, c1 varchar(100), ts timestamp(6));"

i=1
while [ $? -eq 0 ]
do
    iSelectStmt="INSERT INTO testdb.tab(c1) VALUES (CONCAT('Data - ', ROUND(RAND() * 100000, 0)));"
    mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P4006 -e "${iSelectStmt}"
    
    iSelectStmt="SELECT concat('$(tput setaf 7)Executing SELECT on ', @@hostname, '  -  $(tput setaf 3)MaxScale [${maxHost}]$(tput setaf 7) -> ID Retrieved: '), 
                    rpad(coalesce(id, ':(', id), 10, '.'), 
                        IF(COUNT(*)> 0, '$(tput setaf 2)Record Found!$(tput setaf 7)','$(tput setaf 1)! Not Found !$(tput setaf 7)' ) 
                FROM testdb.tab WHERE id = $i;"
    output=$(mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P4006 -e "${iSelectStmt}")
    echo ${output}
    i=$((i+1))
    sleep 0.03
done
