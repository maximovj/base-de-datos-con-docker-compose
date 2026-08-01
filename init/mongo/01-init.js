// Crear usuario para la base de datos
db = db.getSiblingDB('devdb');

db.createUser({
    user: 'devuser',
    pwd: 'devpassword',
    roles: [
        {
            role: 'readWrite',
            db: 'devdb'
        }
    ]
});

// Crear colección de ejemplo
db.createCollection('users');

// Insertar datos de prueba
db.users.insertMany([
    {
        username: 'admin',
        email: 'admin@example.com',
        created_at: new Date()
    },
    {
        username: 'developer',
        email: 'dev@example.com',
        created_at: new Date()
    }
]);