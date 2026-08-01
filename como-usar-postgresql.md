# PostgreSQL 16.14 + Docker compose

### Credenciales de bases de datos para PostgreSQL 16.14

```shell
# Credenciales de bases de datos MySQL 8.4
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
```

### Como usar PostgreSQL 16.14 + Docker compose 

```shell
# Levantar la base  de datos de PostgreSQL 16.14 usando docker compose
docker compose -f docker-compose-postgres.yml up -d 

# Ver estado de la base  de datos de PostgreSQL 16.14 usando docker compose
docker compose -f docker-compose-postgres.yml ps

# Ver logs de la base  de datos de PostgreSQL 16.14 usando docker compose
docker compose -f docker-compose-postgres.yml logs

# postgres_docker es el servicio, psql es el comando
docker compose -f docker-compose-postgres.yml exec postgres_docker psql -U postgres -d postgres

# Detener la base  de datos de PostgreSQL 16.14 usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-postgres.yml down
```

### Conexión a PostgreSQL 16.14 + Docker

**Formato estándar de URI para PostgreSQL**

```shell
# =====================================================
# URI CORRECTAS PARA POSTGRESQL EN DOCKER
# =====================================================

# 1. Desde el HOST (tu PC)
# - usuario: postgres (o el que hayas configurado)
# - contraseña: la que configuraste (ej: 123456)
# - host: localhost (o 127.0.0.1)
# - puerto: 5432 (default de PostgreSQL)
# - base_datos: el nombre REAL de tu BD (NO el nombre del contenedor)
postgresql://postgres:postgres@localhost:5432/postgres

# 2. Desde otro contenedor en la misma red Docker
# - host: postgres_docker (nombre del contenedor/servicio)
# - SOLO funciona si ambos contenedores están en la misma red
postgresql://postgres:postgres@postgres_docker:5432/postgres

# 3. Desde el HOST (Windows/Mac con Docker Desktop)
# - host.docker.internal es un DNS especial para acceder al host
postgresql://postgres:postgres@host.docker.internal:5432/postgres

# 4. Con parámetros adicionales (recomendado para desarrollo)
# - sslmode=disable: desactiva SSL (común en desarrollo local)
postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable

# 5. Si tu BD se llama "postgres" (es posible)
# - EL NOMBRE DE LA BD PUEDE SER postgres
# - Pero el usuario y contraseña SÍ son obligatorios
postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable
```

**Conectar desde otro contenedor en la misma red**

NOTA: Si usas contedor docker para conectarse a PostgreSQL 16.14 no olvides usar `--network dev_network`
para estar en la misma `network`

```shell
# Conectar desde otro contenedor en la misma red
# Conectar interactivamente a PostgreSQL
docker run --rm -it --network container:postgres_docker postgres:16-alpine psql -h postgres_docker -U postgres -d postgres -W=postgres
```