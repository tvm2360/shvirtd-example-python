# Задание 1

[Dockerfile.python](Dockerfile.python) 

[.dockerignore](.dockerignore)

ENV-переменные DB_HOST, DB_USER, DB_NAME заданы внутри со значениями по умолчанию из задания. DB_PASSWORD предусматривает внешнее определение.
Если проекту не требуется виртуальное окружение, строка: 
```dockerfile
...
RUN python3 -m venv venv && . venv/bin/activate
...
```
удаляется.

Проверка:
```bash
docker build --check -f Dockerfile.python . 
```
Создание образа контейнера:
```bash
docker build -t tvm2360/my_app:latest -f Dockerfile.python .
```
Образ доступен для скачивания:
```bash
docker pull tvm2360/my_app:latest
```
Поскольку python-приложение предусматривает взаимодействие с СУБД MySQL, для проверки работоспособности будем использовать
образ контейнера MariaDB. Загружаем образ:
```bash
docker pull mariadb:10.6.4-focal
```
Запускаем контейнер с присвоением ENV-переменных MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD значениями из задания, MYSQL_ROOT_PASSWORD значением по собственному усмотрению:
```bash
docker run -d --rm --name mysql -e MYSQL_ROOT_PASSWORD="p@ssw0rd" -e MYSQL_DATABASE="example" -e MYSQL_USER="app" -e MYSQL_PASSWORD="very_strong" -e MYSQL_ROOT_HOST="%" -p 127.0.0.1:3306:3306 mariadb:10.6.4-focal
```
Проверяем успешность запуска контейнера:
```bash
docker ps | grep mysql && netstat -tlpn | grep 3306
```
Запускаем контейнер с python-приложением. Значения ENV-переменных DB_HOST, DB_USER, DB_NAME установлены заданием по умолчанию внутри образа контейнера и могут быть изменены (-e DB_HOST="..."). 
Присваиваем значение из задания для DB_PASSWORD и передаем его в контейнер:
```bash
docker run --rm --network=host -e DB_PASSWORD="very_strong" tvm2360/my_app:latest
```
Получаем похожее сообщение:
```cmd
 127.0.0.1 app very_strong example
 * Serving Flask app 'main'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://10.0.2.19:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 524-090-493
```

![Задача 1](https://github.com/user-attachments/assets/a4339bcc-e887-4a53-82ad-e2ff7ec30ce8)

Проверяем curl http://localhost:5000, в консоле python-приложения:
```cmd
10.0.2.19 - - [22/Dec/2024 19:16:40] "GET / HTTP/1.1" 200 -
```

Для управления названием используемой таблицы через ENV переменную (DB_TABLE), main.py:
```python
from flask import Flask
from flask import request
import os
import mysql.connector
from datetime import datetime
app = Flask(__name__)
db_host=os.environ.get('DB_HOST')
db_user=os.environ.get('DB_USER')
db_password=os.environ.get('DB_PASSWORD')
db_database=os.environ.get('DB_NAME')
db_table=os.environ.get('DB_TABLE')
# Подключение к базе данных MySQL
db = mysql.connector.connect(
host=db_host,
user=db_user,
password=db_password,
database=db_database,
autocommit=True )
cursor = db.cursor()
# SQL-запрос для создания таблицы в БД
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {db_database}.{db_table} (
id INT AUTO_INCREMENT PRIMARY KEY,
request_date DATETIME,
request_ip VARCHAR(255)
)
"""
cursor.execute(create_table_query)
@app.route('/')
def index():
    # Получение IP-адреса пользователя
    ip_address = request.headers.get('X-Forwarded-For')

    # Запись в базу данных
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    query = f"INSERT INTO {db_table} (request_date, request_ip) VALUES (%s, %s)"
    values = (current_time, ip_address)
    cursor.execute(query, values)
    db.commit()

    return f'TIME: {current_time}, IP: {ip_address}'
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
```
# Задание 2
Результататы сканирования:
![Задача 2](https://github.com/user-attachments/assets/ea970fc8-aca8-43c6-813b-49f45e02623d)

Отчет о результатах сканирования:
[vulnerabilities.csv](https://github.com/user-attachments/files/18233978/vulnerabilities.csv)

# Задание 3
[compose.yaml](compose.yaml)
```cmd
curl -L http://127.0.0.1:8090
TIME: 2024-12-22 21:44:12, IP: 127.0.0.1
```
![Задача 3](https://github.com/user-attachments/assets/48fff586-cb94-436a-a98a-5f8430699ed7)

# Задание 4
![Задача 4](https://github.com/user-attachments/assets/054572dc-f39f-4090-8965-43b9001adb52)
[get_app.sh](get_app.sh)
# Задание 5
Архивация БД вручную.
-

Скрипт запуска контейнера:
[backup_manual.sh](backup_manual.sh)
```cmd
#!/bin/bash

source .env
pref=$(date +"%s_%Y-%m-%d")
docker run --entrypoint "" -v /opt/backup:/backup --link="db:db" --network=shvirtd-example-python_backend --rm -it schnitzler/mysqldump \
mysqldump --opt -h db -u $MYSQL_USER -p$MYSQL_PASSWORD "--result-file=/backup/DB_dump_$pref.sql" $MYSQL_DATABASE
```
Результат:

![Задача 5](https://github.com/user-attachments/assets/c8924a53-ee85-4744-af0a-4cf5ebd0fab3)

Архивация БД по расписанию.
-

Расписание 
[crontab](crontab): 

```cmd
*/1       *       *       *       *       sh /usr/local/bin/backup.sh
```
Скрипт для запуска в контейнере
[baskup.sh](baskup.sh):

```cmd
#!/bin/sh
now=$(date +"%s_%Y-%m-%d")
/usr/bin/mysqldump --opt -h db -u ${MYSQL_USER} -p${MYSQL_PASSWORD} "--result-file=/backup/${now}_${MYSQL_DATABASE}.sql" ${MYSQL_DATABASE} 
```
Скрипт запуска контейнера
[backup_cron.sh](backup_cron.sh):
```cmd
#!/bin/bash
sed "s/\"//g" .env > .env_opt
pref=$(/usr/bin/date +"%s_%Y-%m-%d")
chmod +x ./backup.sh
/usr/bin/docker run -d -v /opt/backup:/backup:rw -v ./crontab:/var/spool/cron/crontabs/root:ro -v ./backup.sh:/usr/local/bin/backup.sh:ro \
--link="db:db" --network=shvirtd-example-python_backend --env-file .env_opt --rm -it schnitzler/mysqldump /bin/bash
```
Результат:

![Задание 5 cron](https://github.com/user-attachments/assets/ad474900-ea15-41a5-b63f-ad7710bde85a)


# Задание 6
![Задача 6 dive](https://github.com/user-attachments/assets/3ba08b62-dcb3-428e-8959-ed3460c3536b)
![Задача 6 docker save](https://github.com/user-attachments/assets/7a31edf8-bbe9-41f3-964a-3b02496ef93e)

# Задание 6.1
![Задача 6 1](https://github.com/user-attachments/assets/3f9e7426-1592-4f89-b5f3-9fb095bc15f4)





