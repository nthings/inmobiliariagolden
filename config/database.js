// config/database.js
const env = process.env.NODE_ENV;
let connection = {
    'connection': {
        'host': 'localhost',
        'user': 'root',
        'password': '',
        'port': 4000
    },
    'database': 'inmobiliariagolden',
    'users_table': 'asesores'
};
if (env === 'production') {
    connection = {
        'connection': {
            'host': process.env.DB_HOST,
            'user': process.env.DB_USER,
            'password': process.env.DB_PASS,
            'port': process.env.DB_PORT
        },
        'database': process.env.DB_NAME,
        'users_table': 'asesores'
    };
}
module.exports = connection;