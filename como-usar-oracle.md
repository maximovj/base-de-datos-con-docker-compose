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

### Conexión a Oracle 21.0 + Docker

**Formato estándar de URI para Oracle**

```shell
# =====================================================
# URI CORRECTAS PARA ORACLE EN DOCKER
# =====================================================

# 1. Desde el HOST (tu PC) - Formato SID
# - usuario: oracleuser (o el que hayas configurado)
# - contraseña: oraclepassword (la que configuraste)
# - host: localhost (o 127.0.0.1)
# - puerto: 1521 (default de Oracle)
# - SID: XE (nombre de la instancia)
jdbc:oracle:thin:oracleuser/oraclepassword@localhost:1521:XE

# 2. Desde el HOST (tu PC) - Formato Service Name (RECOMENDADO)
# - Usa // antes del host para indicar Service Name
# - XEPDB1 es el nombre del PDB (Pluggable Database)
jdbc:oracle:thin:oracleuser/oraclepassword@//localhost:1521/XEPDB1

# 3. Desde otro contenedor en la misma red Docker
# - host: oracle_docker (nombre del contenedor/servicio)
# - SOLO funciona si ambos contenedores están en la misma red dev_network
jdbc:oracle:thin:oracleuser/oraclepassword@//oracle_docker:1521/XEPDB1

# 4. Desde el HOST (Windows/Mac con Docker Desktop)
# - host.docker.internal es un DNS especial para acceder al host
jdbc:oracle:thin:oracleuser/oraclepassword@//host.docker.internal:1521/XEPDB1

# 5. Con formato TNS (más detallado)
# - Útil para conexiones avanzadas o cuando necesitas configuración específica
jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XEPDB1)))

# 6. Conexión como usuario SYS (Administrador)
# - Para tareas administrativas
# - connection_type=SYS indica que es conexión como SYS
jdbc:oracle:thin:sys/oraclepassword@//localhost:1521/XE?connection_type=SYS

# 7. Con parámetros adicionales (recomendado para desarrollo)
# - defaultNChar=true: soporte para caracteres Unicode
# - oracle.net.CONNECT_TIMEOUT=30000: timeout de conexión (ms)
# - oracle.jdbc.ReadTimeout=60000: timeout de lectura (ms)
jdbc:oracle:thin:oracleuser/oraclepassword@//localhost:1521/XEPDB1?defaultNChar=true&oracle.net.CONNECT_TIMEOUT=30000

# 8. Para aplicaciones Spring Boot (sin credenciales en URL)
# - Usa propiedades separadas para usuario y contraseña
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
spring.datasource.username=oracleuser
spring.datasource.password=oraclepassword
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver

# 9. Con pool de conexiones (Tomcat, HikariCP)
# - maxActive=10: máximo de conexiones activas
# - maxWait=30000: tiempo de espera para conexión (ms)
jdbc:oracle:thin:oracleuser/oraclepassword@//localhost:1521/XEPDB1?maxActive=10&maxWait=30000

# 10. Con SSL/TLS habilitado
# - Requiere configuración adicional de certificados
jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCPS)(HOST=localhost)(PORT=2484))(CONNECT_DATA=(SERVICE_NAME=XEPDB1))(SECURITY=(SSL_SERVER_CERT_DN=\"CN=localhost\")))

# 11. Para conectar a la base de datos ROOT (CDB)
# - Acceso a nivel de contenedor, no recomendado para aplicaciones
jdbc:oracle:thin:oracleuser/oraclepassword@localhost:1521:XE

# 12. Para conectar al PDB (Pluggable Database) - FORMATO CORTO
# - La forma más común y recomendada
jdbc:oracle:thin:@localhost:1521/XEPDB1

# 13. Con variables de entorno en Docker Compose
# - Para usar desde otros servicios en docker-compose
SPRING_DATASOURCE_URL=jdbc:oracle:thin:@//oracle_docker:1521/XEPDB1
SPRING_DATASOURCE_USERNAME=oracleuser
SPRING_DATASOURCE_PASSWORD=oraclepassword

# 14. Para conectar desde Node.js (con oracledb)
# - Formato de conexión para node-oracledb
{
  user: "oracleuser",
  password: "oraclepassword",
  connectString: "localhost:1521/XEPDB1"
}

# 15. Para Python (con cx_Oracle)
# - Formato de conexión para cx_Oracle
cx_Oracle.connect("oracleuser/oraclepassword@localhost:1521/XEPDB1")

# 16. Para conectar a un servicio específico con instancia
# - Especifica tanto INSTANCE_NAME como SERVICE_NAME
jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(INSTANCE_NAME=XE)(SERVICE_NAME=XEPDB1)))

# 17. Para conexión con TNS_ADMIN (archivo tnsnames.ora)
# - Útil cuando usas un archivo tnsnames.ora
# - Se debe configurar TNS_ADMIN como variable de entorno
jdbc:oracle:thin:@XE

# 18. Con parámetros de rendimiento
# - prefetchRows=100: número de filas a prefetch
# - fetchSize=50: tamaño de fetch por defecto
jdbc:oracle:thin:oracleuser/oraclepassword@//localhost:1521/XEPDB1?defaultRowPrefetch=100&defaultFetchSize=50

# =====================================================
# NOTAS IMPORTANTES PARA ORACLE:
# =====================================================

# 1. DIFERENCIA ENTRE SID Y SERVICE NAME:
#    - SID (XE): Identificador único de la instancia Oracle
#    - Service Name (XEPDB1): Nombre del servicio, usado para PDBs
#    - RECOMENDADO: Usar Service Name para conexiones modernas

# 2. PUERTO DEFAULT:
#    - 1521: Puerto estándar para Oracle
#    - 5500: Puerto para EM Express (Enterprise Manager)

# 3. USUARIOS COMUNES:
#    - oracleuser: Tu usuario de aplicación (creado con APP_USER)
#    - system: Usuario administrativo
#    - sys: Superusuario (requiere conexión especial)

# 4. FORMATO DE SERVICE NAME:
#    - Debe usar // antes del host
#    - Ejemplo: //localhost:1521/XEPDB1

# 5. DOCKER SPECÍFICO:
#    - oracle_docker: Nombre del contenedor (desde otros contenedores)
#    - localhost: Desde tu máquina host
#    - host.docker.internal: Desde contenedores en Windows/Mac

# 6. TIMEZONE Y CARACTERES:
#    - defaultNChar=true: Para soporte Unicode
#    - La BD está configurada con AL32UTF8 (Character Set)
```

**Conectar desde otro contenedor en la misma red**

NOTA: Si usas contedor docker para conectarse a Oracle 21.0 no olvides usar `--network dev_network` para estar en la misma network

```shell
# Conectar desde otro contenedor en la misma red
# Conectar interactivamente a Mongo
docker run --rm -it --network container:oracle_docker --entrypoint sqlplus gvenzl/oracle-xe:21-slim oracleuser/oraclepassword@XEPDB1
```