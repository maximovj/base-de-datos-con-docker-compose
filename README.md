# Base de datos con Docker Compose

Este repositorio contiene base de datos para arracar o levantarlos con `docker compose`

# Requisitos

- Docker Compose version v5.3.1
- Docker version 29.7.0, build c1eba93
- Docker images:
  - postgres:16-alpine
  - mysql:8.4
  - mongo:7.0

# Docker imagenes en memoria

```shell
$ docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
REPOSITORY          TAG         SIZE
mysql               8.4         1.13GB
postgres            16-alpine   420MB
mongo               7.0         1.19GB
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

