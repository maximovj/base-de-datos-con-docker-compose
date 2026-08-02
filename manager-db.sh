#!/bin/bash

# =============================================
# Script interactivo para gestionar bases de datos de desarrollo
# =============================================

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Directorio base del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"

# Crear estructura de directorios de backups si no existe
create_backup_dirs() {
    mkdir -p "${BACKUP_DIR}/postgres"
    mkdir -p "${BACKUP_DIR}/mysql"
    mkdir -p "${BACKUP_DIR}/mongo"
    mkdir -p "${BACKUP_DIR}/oracle"
}

# Limpiar pantalla
clear

# Función para mostrar el encabezado
show_header() {
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║          🗄️  GESTOR DE BASES DE DATOS DESARROLLO          ║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para iniciar una base de datos
start_db() {
    local name=$1
    local compose_file=$2
    
    echo -e "${BLUE}[INFO]${NC} Iniciando $name..."
    
    if docker compose -f "$compose_file" up -d 2>/dev/null; then
        echo -e "${GREEN}[✔]${NC} $name iniciado correctamente"
        return 0
    else
        echo -e "${RED}[✘]${NC} Error al iniciar $name"
        return 1
    fi
}

# Función para detener una base de datos
stop_db() {
    local name=$1
    local compose_file=$2
    
    echo -e "${BLUE}[INFO]${NC} Deteniendo $name..."
    if docker compose -f "$compose_file" down 2>/dev/null; then
        echo -e "${GREEN}[✔]${NC} $name detenido"
        return 0
    else
        echo -e "${RED}[✘]${NC} Error al detener $name"
        return 1
    fi
}

# Función para crear backup de PostgreSQL
backup_postgres() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${BACKUP_DIR}/postgres/backup_${timestamp}.sql"
    
    echo -e "${BLUE}[INFO]${NC} Creando backup de PostgreSQL..."
    
    # Obtener el nombre del contenedor de PostgreSQL
    local container=$(docker ps --format "{{.Names}}" | grep -i "postgres" | head -1)
    
    if [ -z "$container" ]; then
        echo -e "${RED}[✘]${NC} No se encontró el contenedor de PostgreSQL corriendo"
        return 1
    fi
    
    # Obtener credenciales del docker-compose o usar defaults
    local db_user=$(grep -A 5 "POSTGRES_USER" docker-compose-postgres.yml | grep -v "POSTGRES_PASSWORD" | grep "POSTGRES_USER" | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_password=$(grep "POSTGRES_PASSWORD" docker-compose-postgres.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_name=$(grep "POSTGRES_DB" docker-compose-postgres.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    
    # Si no se encuentran las credenciales, usar defaults
    [ -z "$db_user" ] && db_user="postgres"
    [ -z "$db_password" ] && db_password="postgres"
    [ -z "$db_name" ] && db_name="postgres"
    
    # Ejecutar pg_dump dentro del contenedor
    if docker exec "$container" pg_dump -U "$db_user" -d "$db_name" > "$backup_file" 2>/dev/null; then
        echo -e "${GREEN}[✔]${NC} Backup de PostgreSQL creado: ${backup_file}"
        echo -e "    📊 Tamaño: $(du -h "$backup_file" | cut -f1)"
        return 0
    else
        echo -e "${RED}[✘]${NC} Error al crear backup de PostgreSQL"
        rm -f "$backup_file"
        return 1
    fi
}

# Función para crear backup de MySQL
backup_mysql() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${BACKUP_DIR}/mysql/backup_${timestamp}.sql"
    
    echo -e "${BLUE}[INFO]${NC} Creando backup de MySQL..."
    
    # Obtener el nombre del contenedor de MySQL
    local container=$(docker ps --format "{{.Names}}" | grep -i "mysql" | head -1)
    
    if [ -z "$container" ]; then
        echo -e "${RED}[✘]${NC} No se encontró el contenedor de MySQL corriendo"
        return 1
    fi
    
    # Obtener credenciales del docker-compose o usar defaults
    local db_user=$(grep "MYSQL_USER" docker-compose-mysql.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_password=$(grep "MYSQL_PASSWORD" docker-compose-mysql.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_root_password=$(grep "MYSQL_ROOT_PASSWORD" docker-compose-mysql.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_name=$(grep "MYSQL_DATABASE" docker-compose-mysql.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    
    # Si no se encuentran las credenciales, usar defaults
    [ -z "$db_user" ] && db_user="root"
    [ -z "$db_password" ] && db_password="$db_root_password"
    [ -z "$db_root_password" ] && db_root_password="root"
    [ -z "$db_name" ] && db_name="mysql"
    
    # Ejecutar mysqldump dentro del contenedor
    if docker exec "$container" mysqldump -u "$db_user" -p"$db_password" --all-databases > "$backup_file" 2>/dev/null; then
        echo -e "${GREEN}[✔]${NC} Backup de MySQL creado: ${backup_file}"
        echo -e "    📊 Tamaño: $(du -h "$backup_file" | cut -f1)"
        return 0
    else
        echo -e "${RED}[✘]${NC} Error al crear backup de MySQL"
        rm -f "$backup_file"
        return 1
    fi
}

# Función para crear backup de MongoDB
backup_mongo() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_dir="${BACKUP_DIR}/mongo/backup_${timestamp}"
    
    echo -e "${BLUE}[INFO]${NC} Creando backup de MongoDB..."
    
    # Obtener el nombre del contenedor de MongoDB
    local container=$(docker ps --format "{{.Names}}" | grep -i "mongo" | head -1)
    
    if [ -z "$container" ]; then
        echo -e "${RED}[✘]${NC} No se encontró el contenedor de MongoDB corriendo"
        return 1
    fi
    
    # Obtener credenciales del docker-compose o usar defaults
    local db_user=$(grep "MONGO_INITDB_ROOT_USERNAME" docker-compose-mongo.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_password=$(grep "MONGO_INITDB_ROOT_PASSWORD" docker-compose-mongo.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_name=$(grep "MONGO_INITDB_DATABASE" docker-compose-mongo.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    
    # Crear directorio de backup
    mkdir -p "$backup_dir"
    
    # Ejecutar mongodump dentro del contenedor
    if [ -n "$db_user" ] && [ -n "$db_password" ]; then
        docker exec "$container" mongodump --username="$db_user" --password="$db_password" --authenticationDatabase=admin --out=/tmp/backup 2>/dev/null
    else
        docker exec "$container" mongodump --out=/tmp/backup 2>/dev/null
    fi
    
    if [ $? -eq 0 ]; then
        # Copiar los archivos de backup desde el contenedor
        docker cp "$container:/tmp/backup/." "$backup_dir/" 2>/dev/null
        docker exec "$container" rm -rf /tmp/backup 2>/dev/null
        
        echo -e "${GREEN}[✔]${NC} Backup de MongoDB creado: ${backup_dir}"
        echo -e "    📊 Tamaño: $(du -sh "$backup_dir" | cut -f1)"
        return 0
    else
        echo -e "${RED}[✘]${NC} Error al crear backup de MongoDB"
        rm -rf "$backup_dir"
        return 1
    fi
}

# Función para crear backup de Oracle XE
backup_oracle() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${BACKUP_DIR}/oracle/backup_${timestamp}.dmp"
    
    echo -e "${BLUE}[INFO]${NC} Creando backup de Oracle XE..."
    
    # Obtener el nombre del contenedor de Oracle
    local container=$(docker ps --format "{{.Names}}" | grep -i "oracle" | head -1)
    
    if [ -z "$container" ]; then
        echo -e "${RED}[✘]${NC} No se encontró el contenedor de Oracle XE corriendo"
        return 1
    fi
    
    # Obtener credenciales del docker-compose o usar defaults
    local db_user=$(grep "ORACLE_PDB" docker-compose-oracle.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    local db_password=$(grep "ORACLE_PASSWORD" docker-compose-oracle.yml | head -1 | awk -F: '{print $2}' | tr -d ' "')
    
    [ -z "$db_user" ] && db_user="XEPDB1"
    [ -z "$db_password" ] && db_password="oracle"
    
    # Ejecutar expdp dentro del contenedor (más simple para Oracle XE)
    if docker exec "$container" bash -c "echo 'expdp system/${db_password}@${db_user} FULL=Y DIRECTORY=DATA_PUMP_DIR DUMPFILE=backup.dmp LOGFILE=backup.log' | sqlplus -s system/${db_password}@${db_user}" 2>/dev/null; then
        # Copiar el archivo de backup desde el contenedor
        docker cp "$container:/opt/oracle/admin/XE/dpdump/backup.dmp" "$backup_file" 2>/dev/null
        
        if [ -f "$backup_file" ]; then
            echo -e "${GREEN}[✔]${NC} Backup de Oracle XE creado: ${backup_file}"
            echo -e "    📊 Tamaño: $(du -h "$backup_file" | cut -f1)"
            # Limpiar el archivo temporal en el contenedor
            docker exec "$container" rm -f /opt/oracle/admin/XE/dpdump/backup.dmp /opt/oracle/admin/XE/dpdump/backup.log 2>/dev/null
            return 0
        else
            echo -e "${RED}[✘]${NC} Error al crear backup de Oracle XE"
            return 1
        fi
    else
        echo -e "${RED}[✘]${NC} Error al crear backup de Oracle XE"
        return 1
    fi
}

# Función para mostrar el estado completo
show_status() {
    echo -e "\n${BOLD}${BLUE}📊 ESTADO DE BASES DE DATOS${NC}"
    echo "─────────────────────────────────────────"
    
    # PostgreSQL
    if docker ps --format "{{.Names}}" | grep -qi "postgres"; then
        echo -e "${GREEN}●${NC} PostgreSQL: ${GREEN}Corriendo${NC}"
    else
        echo -e "${RED}○${NC} PostgreSQL: ${RED}Detenido${NC}"
    fi
    
    # MySQL
    if docker ps --format "{{.Names}}" | grep -qi "mysql"; then
        echo -e "${GREEN}●${NC} MySQL: ${GREEN}Corriendo${NC}"
    else
        echo -e "${RED}○${NC} MySQL: ${RED}Detenido${NC}"
    fi
    
    # MongoDB
    if docker ps --format "{{.Names}}" | grep -qi "mongo"; then
        echo -e "${GREEN}●${NC} MongoDB: ${GREEN}Corriendo${NC}"
    else
        echo -e "${RED}○${NC} MongoDB: ${RED}Detenido${NC}"
    fi
    
    # Oracle XE
    if docker ps --format "{{.Names}}" | grep -qi "oracle"; then
        echo -e "${GREEN}●${NC} Oracle XE: ${GREEN}Corriendo${NC}"
    else
        echo -e "${RED}○${NC} Oracle XE: ${RED}Detenido${NC}"
    fi
    
    echo -e "\n${BOLD}${BLUE}📋 CONTENEDORES ACTIVOS${NC}"
    echo "─────────────────────────────────────────"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No hay contenedores activos"
    echo ""
}

# Función para manejar la selección de bases de datos específicas (start)
select_and_start() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Todas"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}📥 INICIAR BASE DE DATOS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos a iniciar:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        echo -e "${CYAN}0)${NC} Volver al menú principal"
        
        echo ""
        read -p "Opción (0-${#options[@]}): " choice
        
        case $choice in
            0) return ;;
            1) start_db "PostgreSQL" "docker-compose-postgres.yml"; break ;;
            2) start_db "MySQL" "docker-compose-mysql.yml"; break ;;
            3) start_db "MongoDB" "docker-compose-mongo.yml"; break ;;
            4) start_db "Oracle XE" "docker-compose-oracle.yml"; break ;;
            5) 
                start_db "PostgreSQL" "docker-compose-postgres.yml"
                start_db "MySQL" "docker-compose-mysql.yml"
                start_db "MongoDB" "docker-compose-mongo.yml"
                start_db "Oracle XE" "docker-compose-oracle.yml"
                break
                ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para manejar la selección de bases de datos específicas (stop)
select_and_stop() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Todas"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}📤 DETENER BASE DE DATOS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos a detener:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        echo -e "${CYAN}0)${NC} Volver al menú principal"
        
        echo ""
        read -p "Opción (0-${#options[@]}): " choice
        
        case $choice in
            0) return ;;
            1) stop_db "PostgreSQL" "docker-compose-postgres.yml"; break ;;
            2) stop_db "MySQL" "docker-compose-mysql.yml"; break ;;
            3) stop_db "MongoDB" "docker-compose-mongo.yml"; break ;;
            4) stop_db "Oracle XE" "docker-compose-oracle.yml"; break ;;
            5) 
                stop_db "PostgreSQL" "docker-compose-postgres.yml"
                stop_db "MySQL" "docker-compose-mysql.yml"
                stop_db "MongoDB" "docker-compose-mongo.yml"
                stop_db "Oracle XE" "docker-compose-oracle.yml"
                break
                ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para reiniciar bases de datos
select_and_restart() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Todas"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}🔄 REINICIAR BASE DE DATOS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos a reiniciar:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        echo -e "${CYAN}0)${NC} Volver al menú principal"
        
        echo ""
        read -p "Opción (0-${#options[@]}): " choice
        
        case $choice in
            0) return ;;
            1) 
                stop_db "PostgreSQL" "docker-compose-postgres.yml"
                sleep 2
                start_db "PostgreSQL" "docker-compose-postgres.yml"
                break
                ;;
            2) 
                stop_db "MySQL" "docker-compose-mysql.yml"
                sleep 2
                start_db "MySQL" "docker-compose-mysql.yml"
                break
                ;;
            3) 
                stop_db "MongoDB" "docker-compose-mongo.yml"
                sleep 2
                start_db "MongoDB" "docker-compose-mongo.yml"
                break
                ;;
            4) 
                stop_db "Oracle XE" "docker-compose-oracle.yml"
                sleep 2
                start_db "Oracle XE" "docker-compose-oracle.yml"
                break
                ;;
            5) 
                stop_db "PostgreSQL" "docker-compose-postgres.yml"
                stop_db "MySQL" "docker-compose-mysql.yml"
                stop_db "MongoDB" "docker-compose-mongo.yml"
                stop_db "Oracle XE" "docker-compose-oracle.yml"
                sleep 2
                start_db "PostgreSQL" "docker-compose-postgres.yml"
                start_db "MySQL" "docker-compose-mysql.yml"
                start_db "MongoDB" "docker-compose-mongo.yml"
                start_db "Oracle XE" "docker-compose-oracle.yml"
                break
                ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para crear backups
select_and_backup() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Todas"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}💾 CREAR BACKUP${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos para backup:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        echo -e "${CYAN}0)${NC} Volver al menú principal"
        
        echo ""
        read -p "Opción (0-${#options[@]}): " choice
        
        case $choice in
            0) return ;;
            1) backup_postgres; break ;;
            2) backup_mysql; break ;;
            3) backup_mongo; break ;;
            4) backup_oracle; break ;;
            5) 
                echo -e "\n${YELLOW}Creando backups de todas las bases de datos...${NC}\n"
                backup_postgres
                backup_mysql
                backup_mongo
                backup_oracle
                break
                ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para ver logs
view_logs() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}📜 VER LOGS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos para ver logs:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        echo -e "${CYAN}0)${NC} Volver al menú principal"
        
        echo ""
        read -p "Opción (0-${#options[@]}): " choice
        
        case $choice in
            0) return ;;
            1) 
                echo -e "\n${YELLOW}Logs de PostgreSQL (presiona Ctrl+C para salir)${NC}"
                docker compose -f "docker-compose-postgres.yml" logs -f
                ;;
            2) 
                echo -e "\n${YELLOW}Logs de MySQL (presiona Ctrl+C para salir)${NC}"
                docker compose -f "docker-compose-mysql.yml" logs -f
                ;;
            3) 
                echo -e "\n${YELLOW}Logs de MongoDB (presiona Ctrl+C para salir)${NC}"
                docker compose -f "docker-compose-mongo.yml" logs -f
                ;;
            4) 
                echo -e "\n${YELLOW}Logs de Oracle XE (presiona Ctrl+C para salir)${NC}"
                docker compose -f "docker-compose-oracle.yml" logs -f
                ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
    done
}

# Menú principal
main_menu() {
    # Crear estructura de backups al inicio
    create_backup_dirs
    
    while true; do
        clear
        show_header
        
        echo -e "${BOLD}${MAGENTA}📋 MENÚ PRINCIPAL${NC}"
        echo "─────────────────────────────────────────"
        echo -e "${CYAN}1)${NC} Iniciar bases de datos"
        echo -e "${CYAN}2)${NC} Detener bases de datos"
        echo -e "${CYAN}3)${NC} Reiniciar bases de datos"
        echo -e "${CYAN}4)${NC} Ver estado"
        echo -e "${CYAN}5)${NC} Crear backup"
        echo -e "${CYAN}6)${NC} Ver logs"
        echo -e "${CYAN}0)${NC} Salir"
        echo ""
        
        # Mostrar estado rápido
        echo -e "${BOLD}${BLUE}📊 ESTADO RÁPIDO${NC}"
        echo "─────────────────────────────────────────"
        
        # PostgreSQL
        if docker ps --format "{{.Names}}" | grep -qi "postgres"; then
            echo -e "${GREEN}●${NC} PostgreSQL: ${GREEN}Corriendo${NC}"
        else
            echo -e "${RED}○${NC} PostgreSQL: ${RED}Detenido${NC}"
        fi
        
        # MySQL
        if docker ps --format "{{.Names}}" | grep -qi "mysql"; then
            echo -e "${GREEN}●${NC} MySQL: ${GREEN}Corriendo${NC}"
        else
            echo -e "${RED}○${NC} MySQL: ${RED}Detenido${NC}"
        fi
        
        # MongoDB
        if docker ps --format "{{.Names}}" | grep -qi "mongo"; then
            echo -e "${GREEN}●${NC} MongoDB: ${GREEN}Corriendo${NC}"
        else
            echo -e "${RED}○${NC} MongoDB: ${RED}Detenido${NC}"
        fi
        
        # Oracle XE
        if docker ps --format "{{.Names}}" | grep -qi "oracle"; then
            echo -e "${GREEN}●${NC} Oracle XE: ${GREEN}Corriendo${NC}"
        else
            echo -e "${RED}○${NC} Oracle XE: ${RED}Detenido${NC}"
        fi
        
        echo "─────────────────────────────────────────"
        echo ""
        
        read -p "Selecciona una opción (0-6): " main_choice
        
        case $main_choice in
            0) 
                echo -e "\n${GREEN}¡Hasta luego! 👋${NC}"
                exit 0
                ;;
            1) 
                select_and_start
                show_status
                read -p "Presiona Enter para continuar..."
                ;;
            2)
                select_and_stop
                show_status
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                select_and_restart
                show_status
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                show_status
                read -p "Presiona Enter para continuar..."
                ;;
            5)
                select_and_backup
                read -p "Presiona Enter para continuar..."
                ;;
            6)
                view_logs
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Ejecutar menú principal
main_menu