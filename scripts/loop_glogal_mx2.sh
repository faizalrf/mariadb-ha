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
    iStmt="INSERT INTO testdb.tab2(c1) VALUES (CONCAT('Data - ', ROUND(RAND() * 100000, 0)));"
    mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P${Port} -e "${iStmt}"
    
    iStmt="SELECT concat('$(tput setaf 7)SELECT on ', @@hostname, '  -  $(tput setaf 3)MaxPort [${Port}]$(tput setaf 7) ->'), 
                    rpad(coalesce(id, ':(', id), 10, '.'), 
                        IF(COUNT(*)> 0, '$(tput setaf 2)Record Found!$(tput setaf 7)','$(tput setaf 1)! Not Found !$(tput setaf 7)' ) 
                FROM testdb.tab2 WHERE id = $i;"
    output=$(mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P${Port} -e "${iStmt}")
    echo ${output}
    i=$((i+1))
    sleep 0.03
done
