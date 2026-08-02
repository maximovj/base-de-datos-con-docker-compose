# Base de datos con Docker Compose

Este repositorio contiene base de datos para arracar o levantarlos con `docker compose`

# Requisitos

- Docker Compose version v5.3.1
- Docker version 29.7.0, build c1eba93
- Docker images:
  - postgres:16-alpine
  - mysql:8.4
  - mongo:7.0
  - gvenzl/oracle-xe:21-slim

# Docker imagenes en memoria

```shell
$ docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
REPOSITORY          TAG         SIZE
mysql               8.4         1.13GB
postgres            16-alpine   420MB
mongo               7.0         1.19GB
gvenzl/oracle-xe    21-slim     2.58GB
```

# Como usar 

- Pudes consultar la documentación **como usar postgresql**

  - [Como usar PostgreSQL](/como-usar-postgresql.md)

- Pudes consultar la documentación **como usar mysql**

  - [Como usar MySQL](/como-usar-mysql.md)

- Pudes consultar la documentación **como usar mongo**

  - [Como usar MongoDB](/como-usar-mongo.md)

- Pudes consultar la documentación **como usar oracle**

  - [Como usar Oracle XE](/como-usar-oracle.md)

#  Usar gestionar bases de datos de desarrollo

**Solo script shell**

```shell
$ sudo chmod +x ./manager-db.sh
$ ./manager-db.sh
```

### Vistas Previas

![preview_01.png](/screenshots/preview_01.png)

![preview_02.png](/screenshots/preview_02.png)

![preview_03.png](/screenshots/preview_03.png)

![preview_04.png](/screenshots/preview_04.png)

