#!/bin/bash

source .env
pref=$(date +"%s_%Y-%m-%d")
docker run --entrypoint "" -v /opt/backup:/backup --link="db:db" --network=shvirtd-example-python_backend --rm -it schnitzler/mysqldump mysqldump --opt -h db -u $MYSQL_USER -p$MYSQL_PASSWORD "--result-file=/backup/DB_dump_$pref.sql" $MYSQL_DATABASE
