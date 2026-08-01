# Mongo + Docker compose

### Credenciales de bases de datos para Mongo

```shell
# Credenciales de bases de datos Mongo
MONGO_HOST=localhost
MONGO_PORT=27017
MONGO_USER=mongo
MONGO_PASSWORD=mongo
MONGO_DB=mongodb
```

### Como usar MongoDB 7.0 + Docker compose 

```shell
# Levantar la base  de datos de MongoDB 7.0 usando docker compose
docker compose -f docker-compose-mongo.yml up -d 

# Ver estado de la base  de datos de MongoDB 7.0 usando docker compose
docker compose -f docker-compose-mongo.yml ps

# Ver logs de la base  de datos de MongoDB 7.0 usando docker compose
docker compose -f docker-compose-mongo.yml logs

# mongo_docker es el servicio, mongosh es el comando
docker compose -f docker-compose-mongo.yml exec mongo_docker \
mongosh --host mongo_docker -u mongo -p mongo

# Detener la base  de datos de MongoDB 7.0 usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-mongo.yml down
```

### Conexión a MongoDB 7.0 + Docker

NOTA: Si usas contedor docker para conectarse a MongoDB 7.0 no olvides usar `--network dev_network` para estar en la misma network

```shell
# Conectar desde otro contenedor en la misma red
# Conectar interactivamente a Mongo
docker run --rm -it --network container:mongo_docker mongo:7.0 \
mongosh --host mongo_docker -u mongo -p mongo
```

