# Base de datos con Docker Compose

Este repositorio contiene base de datos para arracar o levantarlos con `docker compose`

# Requisitos

- Docker Compose version v5.3.1
- Docker version 29.7.0, build c1eba93
- Docker images:
    - postgres:16-alpine
    - mysql:8.4

# PostgreSQL + Docker compose

```shell
# Levantar la base  de datos de PotsgreSQL usando docker compose
docker compose -f docker-compose-postgres.yml up -d 

# Detener la base  de datos de PotsgreSQL usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-postgres.yml down
```

# MySQL 8.4 + Docker compose

```shell
# Levantar la base  de datos de MySQL 8.4 usando docker compose
docker compose -f docker-compose-mysql.yml up -d 

# Ver estado de la base  de datos de MySQL 8.4 usando docker compose
docker compose -f docker-compose-mysql.yml ps

# Ver logs de la base  de datos de MySQL 8.4 usando docker compose
docker compose -f docker-compose-mysql.yml logs

# Detener la base  de datos de MySQL 8.4 usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-mysql.yml down
```

## Credenciales de bases de datos para MySQL 8.4

```shell
# Credenciales de bases de datos MySQL 8.4
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=mysqluser # también puedes usar root
MYSQL_PASSWORD=mysqlpassword # también puedes usar root
MYSQL_DB=mysqldb
```

# Como usarlo

### Conexión a PostgreSQL + Docker en SpringBoot. 

NOTA: Si usas contedor docker para conectarse a PostgreSQL no olvides usar `--network dev_network`
para estar en la misma `network`

```shell
jdbc:postgresql://host.docker.internal:5432/postgres_docker

jdbc:postgresql://postgres_docker:5432/postgres_docker

jdbc:postgresql://localhost:5432/postgres_docker
```

### Conexión a MySQL + Docker en SpringBoot. 

**Formato estándar de URI para MySQL**

```shell
# 1. PARA CONECTAR DESDE EL HOST (tu PC)
# Usa host.docker.internal en Windows/Mac o localhost en Linux
# Puerto: 3306 (el estándar de MySQL)
# Usuario: mysqluser
# Base de datos: mysqldb
mysql://mysqluser:mysqlpassword@host.docker.internal:3306/mysqldb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true

# 2. PARA CONECTAR DESDE OTRO CONTENEDOR EN LA MISMA RED DOCKER
# Usa el nombre del contenedor como host (mysql8_docker)
# Solo funciona si ambos contenedores están en la misma red
mysql://mysqluser:mysqlpassword@mysql8_docker:3306/mysqldb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true

# 3. PARA CONECTAR DESDE EL HOST (alternativa con localhost)
# Funciona en Linux y también en Windows/Mac con -p 3306:3306 expuesto
mysql://mysqluser:mysqlpassword@localhost:3306/mysqldb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
```

**Conectar desde otro contenedor en la misma red**

NOTA: Si usas contedor docker para conectarse a MySQL 8.4 no olvides usar `--network dev_network`
para estar en la misma `network`

```shell
# Conectar desde otro contenedor en la misma red
docker run --rm -it --network container:mysql8_docker mysql:8.4 mysql -h 127.0.0.1 -u mysqluser -pmysqlpassword 
```

