#!/bin/sh

now=$(date +"%s_%Y-%m-%d")

/usr/bin/mysqldump --opt -h db -u ${MYSQL_USER} -p${MYSQL_PASSWORD} "--result-file=/backup/${now}_${MYSQL_DATABASE}.sql" ${MYSQL_DATABASE}
