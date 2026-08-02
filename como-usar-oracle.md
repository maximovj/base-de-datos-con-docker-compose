# Oracle 21.0 + Docker compose

### Credenciales de bases de datos para Oracle 21.0

```shell
# Credenciales de bases de datos / Oracle 21.0 Conectar al PDB (Recomendado)
ORACLE_HOST=localhost
ORACLE_PORT=1521
ORACLE_USER=oracleuser
ORACLE_PASSWORD=oraclepassword
ORACLE_SERVICE_NAME=XEPDB1
```

```shell
# Credenciales de bases de datos Oracle 21.0  / Conectar como SYS (para administración)
ORACLE_HOST=localhost
ORACLE_PORT=1521
ORACLE_USER=sys
ORACLE_PASSWORD=oraclepassword
ORACLE_SID=xe
ORACLE_CONNECTION_TYPE=SYSDBA
```

### Como usar Oracle 21.0 + Docker compose 

```shell
# Levantar la base  de datos de Oracle 21.0 usando docker compose
docker compose -f docker-compose-oracle.yml up -d 

# Ver estado de la base  de datos de Oracle 21.0 usando docker compose
docker compose -f docker-compose-oracle.yml ps

# Ver logs de la base  de datos de Oracle 21.0 usando docker compose
docker compose -f docker-compose-oracle.yml logs

# Verificación rápida de que todo funciona
docker exec -it oracle_docker sqlplus oracleuser/oraclepassword@XEPDB1

# oracle_docker es el servicio, mongosh es el comando
docker compose -f docker-compose-oracle.yml exec oracle_docker \
sqlplus oracleuser/oraclepassword@XEPDB1

# Detener la base  de datos de Oracle 21.0 usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-oracle.yml down
```