# Mongo + Docker compose

### Credenciales de bases de datos para Mongo

```shell
# Credenciales de bases de datos Mongo
MONGO_HOST=localhost
MONGO_PORT=27017
MONGO_USER=mongouser
MONGO_PASSWORD=mongopassword
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
mongosh --host mongo_docker -u mongouser -p mongopassword

# Detener la base  de datos de MongoDB 7.0 usando docker compose
# NOTA: No se elimina el volumen por lo que los datos de la base de datos persisten
docker compose -f docker-compose-mongo.yml down
```

### Conexión a MongoDB 7.0 + Docker

**Formato estándar de URI para MongoDB**

```shell
# =====================================================
# URI CORRECTAS PARA MONGODB EN DOCKER
# =====================================================

# 1. Desde el HOST (tu PC)
# - usuario: mongouser (o el que hayas configurado)
# - contraseña: la que configuraste (ej: mongopassword)
# - host: localhost (o 127.0.0.1)
# - puerto: 27017 (default de MongoDB)
# - base_datos: el nombre REAL de tu BD (NO el nombre del contenedor)
mongodb://mongouser:mongopassword@localhost:27017/mongodb

# 2. Desde otro contenedor en la misma red Docker
# - host: mongo_docker (nombre del contenedor/servicio)
# - SOLO funciona si ambos contenedores están en la misma red
mongodb://mongouser:mongopassword@mongo_docker:27017/mongodb

# 3. Desde el HOST (Windows/Mac con Docker Desktop)
# - host.docker.internal es un DNS especial para acceder al host
mongodb://mongouser:mongopassword@host.docker.internal:27017/mongodb

# 4. Con parámetros adicionales (recomendado para desarrollo)
# - authSource=admin: especifica la base de datos donde está el usuario
# - retryWrites=true: permite reintentos en escrituras
# - w=majority: nivel de escritura
mongodb://mongouser:mongopassword@localhost:27017/mongodb?authSource=admin&retryWrites=true&w=majority

# 5. Conexión sin autenticación (si no tiene usuario/contraseña)
# - Solo funciona si MongoDB no tiene autenticación habilitada
mongodb://localhost:27017/mongodb

# 6. Para MongoDB Atlas (formato SRV)
# - Usa mongodb+srv:// en lugar de mongodb://
# - SSL/TLS habilitado automáticamente
mongodb+srv://mongouser:mongopassword@cluster0.mongodb.net/mongodb

# 7. Con conjunto de réplicas (Replica Set)
# - Especifica varios hosts y el nombre del replica set
mongodb://mongouser:mongopassword@host1:27017,host2:27017,host3:27017/mongodb?replicaSet=myReplicaSet

# 8. Con opciones de conexión completas
# - maxPoolSize=10: máximo de conexiones en el pool
# - connectTimeoutMS=5000: tiempo de espera de conexión (ms)
mongodb://mongouser:mongopassword@localhost:27017/mongodb?authSource=admin&maxPoolSize=10&connectTimeoutMS=5000&retryWrites=true&w=majority
```

**Conectar desde otro contenedor en la misma red**

NOTA: Si usas contedor docker para conectarse a MongoDB 7.0 no olvides usar `--network dev_network` para estar en la misma network

```shell
# Conectar desde otro contenedor en la misma red
# Conectar interactivamente a Mongo
docker run --rm -it --network container:mongo_docker mongo:7.0 \
mongosh --host mongo_docker -u mongouser -p mongopassword
```

