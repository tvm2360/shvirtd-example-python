Задание 1
-
[Dockerfile.python](Dockerfile.python) [.dockerignore](.dockerignore)

ENV-переменные DB_HOST, DB_USER, DB_NAME заданы внутри со значениями по умолчанию из задания. DB_PASSWORD предусматривает внешнее определение.
Если не требуется виртуальное окружения, строка RUN python3 -m venv venv && . venv/bin/activate удаляется.

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
Присваиваем значение из задания для DB_PASSWORD и передаем ее в контейнер:
```bash
docker run --rm --network=host -e DB_PASSWORD="very_strong" tvm2360/my_app:latest
```
Получаем похожее сообщение:
```bash
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
Проверяем curl http://localhost:5000, в консоле python-приложения:
```bash
10.0.2.19 - - [22/Dec/2024 19:16:40] "GET / HTTP/1.1" 200 -
```
Для управления названием используемой таблицы серез ENV переменную, main.py:
```bash
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







# shvirtd-example-python

Example Flask-application for docker compose training.
## Installation
First, you need to clone this repository:

```bash
git clone https://github.com/netology-code/shvirtd-example-python.git
```

Now, we will need to create a virtual environment and install all the dependencies:

```bash
python3 -m venv venv  # on Windows, use "python -m venv venv" instead
. venv/bin/activate   # on Windows, use "venv\Scripts\activate" instead
pip install -r requirements.txt
python main.py
```
You need to run Mysql database and provide following ENV-variables for connection:  
- DB_HOST (default: '127.0.0.1')
- DB_USER (default: 'app')
- DB_PASSWORD (default: 'very_strong')
- DB_NAME (default: 'example')

The applications will always running on http://localhost:5000.  
To exit venv just type ```deactivate```

## License

This project is licensed under the MIT License (see the `LICENSE` file for details).
