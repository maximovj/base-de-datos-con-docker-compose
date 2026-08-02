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

# Limpiar pantalla
clear

# Función para mostrar el encabezado
show_header() {
    echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║          🗄️  GESTOR DE BASES DE DATOS DESARROLLO            ║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para obtener el nombre del contenedor desde el archivo compose
get_container_name() {
    local compose_file=$1
    
    # Buscar el nombre del contenedor en el archivo compose
    local container_name=$(grep "container_name:" "$compose_file" | head -1 | awk '{print $2}' | tr -d '"')
    
    # Si no encuentra container_name, intentar obtener el nombre del servicio
    if [ -z "$container_name" ]; then
        container_name=$(grep -A 1 "^[a-zA-Z]" "$compose_file" | grep -v ":" | head -1 | tr -d ' ')
    fi
    
    echo "$container_name"
}

# Función para verificar si una base de datos está corriendo
is_db_running() {
    local compose_file=$1
    local container_name=$(get_container_name "$compose_file")
    
    # Si el nombre del contenedor está vacío, intentar con un patrón más flexible
    if [ -z "$container_name" ]; then
        # Buscar cualquier contenedor que tenga el puerto de la base de datos
        case "$compose_file" in
            *postgres*)
                docker ps --format "{{.Names}}" | grep -E "postgres|postgre" | head -1 | grep -q .
                return $?
                ;;
            *mysql*)
                docker ps --format "{{.Names}}" | grep -E "mysql|mariadb" | head -1 | grep -q .
                return $?
                ;;
            *mongo*)
                docker ps --format "{{.Names}}" | grep -E "mongo|mongodb" | head -1 | grep -q .
                return $?
                ;;
            *oracle*)
                docker ps --format "{{.Names}}" | grep -E "oracle|xe" | head -1 | grep -q .
                return $?
                ;;
            *)
                return 1
                ;;
        esac
    fi
    
    # Verificar si el contenedor específico está corriendo
    if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        return 0
    else
        return 1
    fi
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

# Función para mostrar el estado de una base de datos específica
show_db_status() {
    local name=$1
    local compose_file=$2
    
    if is_db_running "$compose_file"; then
        echo -e "${GREEN}●${NC} $name: ${GREEN}Corriendo${NC}"
    else
        echo -e "${RED}○${NC} $name: ${RED}Detenido${NC}"
    fi
}

# Función para mostrar el estado completo
show_status() {
    echo -e "\n${BOLD}${BLUE}📊 ESTADO DE BASES DE DATOS${NC}"
    echo "─────────────────────────────────────────"
    show_db_status "PostgreSQL" "docker-compose-postgres.yml"
    show_db_status "MySQL" "docker-compose-mysql.yml"
    show_db_status "MongoDB" "docker-compose-mongo.yml"
    show_db_status "Oracle XE" "docker-compose-oracle.yml"
    
    echo -e "\n${BOLD}${BLUE}📋 CONTENEDORES ACTIVOS${NC}"
    echo "─────────────────────────────────────────"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No hay contenedores activos"
    echo ""
}

# Función para manejar la selección de bases de datos específicas
select_and_start() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Todas" "Volver"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}📥 INICIAR BASE DE DATOS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos a iniciar:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        
        echo ""
        read -p "Opción (1-${#options[@]}): " choice
        
        case $choice in
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
            6) return ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para manejar la selección de bases de datos específicas (stop)
select_and_stop() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Todas" "Volver"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}📤 DETENER BASE DE DATOS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos a detener:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        
        echo ""
        read -p "Opción (1-${#options[@]}): " choice
        
        case $choice in
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
            6) return ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para reiniciar bases de datos
select_and_restart() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Todas" "Volver"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}🔄 REINICIAR BASE DE DATOS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos a reiniciar:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        
        echo ""
        read -p "Opción (1-${#options[@]}): " choice
        
        case $choice in
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
            6) return ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Función para ver logs
view_logs() {
    local options=(
        "PostgreSQL" "MySQL" "MongoDB" "Oracle XE" "Volver"
    )
    
    while true; do
        echo -e "\n${BOLD}${BLUE}📜 VER LOGS${NC}"
        echo "─────────────────────────────────────────"
        echo "Selecciona la base de datos para ver logs:"
        echo ""
        
        for i in "${!options[@]}"; do
            echo -e "${CYAN}$((i+1)))${NC} ${options[$i]}"
        done
        
        echo ""
        read -p "Opción (1-${#options[@]}): " choice
        
        case $choice in
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
            5) return ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
    done
}

# Función para verificar el estado real de los contenedores
check_container_status() {
    local service_name=$1
    
    # Buscar contenedores que coincidan con el servicio
    local containers=$(docker ps --format "{{.Names}}" | grep -i "$service_name")
    
    if [ -n "$containers" ]; then
        return 0
    else
        return 1
    fi
}

# Menú principal
main_menu() {
    while true; do
        clear
        show_header
        
        echo -e "${BOLD}${MAGENTA}📋 MENÚ PRINCIPAL${NC}"
        echo "─────────────────────────────────────────"
        echo -e "${CYAN}1)${NC} Iniciar bases de datos"
        echo -e "${CYAN}2)${NC} Detener bases de datos"
        echo -e "${CYAN}3)${NC} Reiniciar bases de datos"
        echo -e "${CYAN}4)${NC} Ver estado"
        echo -e "${CYAN}5)${NC} Ver logs"
        echo -e "${CYAN}6)${NC} Salir"
        echo ""
        
        # Mostrar estado rápido usando verificación directa
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
        
        read -p "Selecciona una opción (1-6): " main_choice
        
        case $main_choice in
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
                view_logs
                ;;
            6)
                echo -e "\n${GREEN}¡Hasta luego! 👋${NC}"
                exit 0
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