#!/bin/bash

sed "s/\"//g" .env > .env_opt

pref=$(/usr/bin/date +"%s_%Y-%m-%d")

chmod +x ./backup.sh

/usr/bin/docker run -d -v /opt/backup:/backup:rw -v ./crontab:/var/spool/cron/crontabs/root:ro -v ./backup.sh:/usr/local/bin/backup.sh:ro \
--link="db:db" --network=shvirtd-example-python_backend --env-file .env_opt --rm -it schnitzler/mysqldump /bin/bash