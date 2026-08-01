# Base de datos con Docker Compose

Este repositorio contiene base de datos para arracar o levantarlos con `docker compose`

# Requisitos

- Docker Compose version v5.3.1
- Docker version 29.7.0, build c1eba93
- Docker images:
    - postgres:16-alpine

# PostgreSQL + Docker compose

```shell
# Levantar la base  de datos de PotsgreSQL usando docker compose
docker compose -f docker-compose-postgres.yml up -d 

# Detener la base  de datos de PotsgreSQL usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-postgres.yml down
```

## Credenciales de bases de datos

```shell
# Credenciales de bases de datos
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
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