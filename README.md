Задание 1
-
[Dockerfile.python](Dockerfile.python)

ENV-переменные DB_HOST, DB_USER, DB_NAME заданы внутри со значениями по-умолчанию. DB_PASSWORD предусматривает внешнее определение.

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
docker run -d --rm --network=host --name mysql -e MYSQL_ROOT_PASSWORD="SuPeRsEcReT"  -e MYSQL_DATABASE="example" -e MYSQL_USER="app" -e MYSQL_PASSWORD="very_strong" -e MYSQL_ROOT_HOST="%" mariadb:10.6.4-focal
```
Проверяем успешность запуска контейнера:
```bash
docker ps | grep mysql
netstat -tlpn | grep "3306"


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
