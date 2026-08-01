# MySQL 8.4 + Docker compose

### Credenciales de bases de datos para MySQL 8.4

```shell
# Credenciales de bases de datos MySQL 8.4
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=mysqluser # también puedes usar root
MYSQL_PASSWORD=mysqlpassword # también puedes usar root
MYSQL_DB=mysqldb
```

### Como usar MySQL 8.4 + Docker compose 

```shell
# Levantar la base  de datos de MySQL 8.4 usando docker compose
docker compose -f docker-compose-mysql.yml up -d 

# Ver estado de la base  de datos de MySQL 8.4 usando docker compose
docker compose -f docker-compose-mysql.yml ps

# Ver logs de la base  de datos de MySQL 8.4 usando docker compose
docker compose -f docker-compose-mysql.yml logs

# mysql_docker es el servicio, psql es el comando
docker compose -f docker-compose-postgres.yml exec mysql_docker mysql -h localhost -u mysqluser -pmysqlpassword

# Detener la base  de datos de MySQL 8.4 usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-mysql.yml down
```

### Conexión a MySQL + Docker

**Formato estándar de URI para MySQL**

```shell
# 1. PARA CONECTAR DESDE EL HOST (tu PC)
# Usa host.docker.internal en Windows/Mac o localhost en Linux
# Puerto: 3306 (el estándar de MySQL)
# Usuario: mysqluser
# Base de datos: mysqldb
mysql://mysqluser:mysqlpassword@host.docker.internal:3306/mysqldb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true

# 2. PARA CONECTAR DESDE OTRO CONTENEDOR EN LA MISMA RED DOCKER
# Usa el nombre del contenedor como host (mysql_docker)
# Solo funciona si ambos contenedores están en la misma red
mysql://mysqluser:mysqlpassword@mysql_docker:3306/mysqldb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true

# 3. PARA CONECTAR DESDE EL HOST (alternativa con localhost)
# Funciona en Linux y también en Windows/Mac con -p 3306:3306 expuesto
mysql://mysqluser:mysqlpassword@localhost:3306/mysqldb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
```

**Conectar desde otro contenedor en la misma red**

NOTA: Si usas contedor docker para conectarse a MySQL 8.4 no olvides usar `--network dev_network`
para estar en la misma `network`

```shell
# Conectar desde otro contenedor en la misma red
docker run --rm -it --network container:mysql_docker mysql:8.4 mysql -h mysql_docker -u mysqluser -pmysqlpassword
```
