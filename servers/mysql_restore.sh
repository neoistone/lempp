#!/bin/bash
 
# folder where dump files are copied
directory="/tmp"
# mariadb credentials
db_user="root"
db_password=`/opt/sneoistone`
 
# list all sql files in $directory
files=$(find $directory -type f -name "*.sql")
 
# put all sql files into $sql_dumps array
 
declare -a sql_dumps=($files)
 
# Users are dumped to users.sql file.
 
for sql_dump in "${sql_dumps[@]}"; do
    if [[ $sql_dump == *"users.sql"* ]]; then
       # import users and privileges
       sudo mysql -u$db_user -p$db_password mysql < $directory/users.sql
    else
        # import databases
        sudo mysql -u$db_user -p$db_password < $sql_dump
    fi
done
 
# Apply changes
 
sudo mysql -u$db_user -p$db_password -e "FLUSH PRIVILEGES"
