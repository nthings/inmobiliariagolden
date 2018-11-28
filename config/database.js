// config/database.js
const env = process.env.NODE_ENV
let config = {
    'connection': {
        'host': 'localhost',
        'user': 'golden',
        'password': 'casitas'
    },
	'database': 'inmobiliariagolden',
    'users_table': 'asesores'
};
if (env === 'production') {
    config = {
        'connection': {
            'host': process.env.DB_HOST,
            'user': process.env.DB_USER,
            'password': process.env.DB_PASS
        },
        'database': process.env.DB_NAME,
        'users_table': 'asesores'
    };
}
module.exports = config;