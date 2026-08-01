-- Crear esquemas adicionales
CREATE SCHEMA IF NOT EXISTS app_schema;

-- Crear tablas de ejemplo
CREATE TABLE IF NOT EXISTS app_schema.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de prueba
INSERT INTO app_schema.users (username, email) VALUES
('admin', 'admin@example.com'),
('developer', 'dev@example.com')
ON CONFLICT (username) DO NOTHING;