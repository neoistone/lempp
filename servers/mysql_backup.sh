#!/bin/bash
 
# mariadb credentials
db_user="root"
db_password=`/opt/sneoistone`
 
# get all databases
 
databases=$(sudo mysql -uroot -pmypass -sse "show databases")
 
# Create an array and remove system databases
 
declare -a dbs=($(echo $databases | sed -e 's/information_schema//g;s/mysql//g;s/performance_schema//g'))
 
# Loop through an array and backup databases to separate file
 
 
# repair
 
mysqlcheck -u$db_user -p$db_password --auto-repair --check --all-databases
 
# export databases
 
for db in "${dbs[@]}"; do
 
   mysqldump -u$db_user -p$db_password --databases $db > $db.sql
 
done
 
# export users and privileges
 
mysqldump -u$db_user -p$db_password mysql user > users.sql
