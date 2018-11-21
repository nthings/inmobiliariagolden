// config/database.js
module.exports = {
    'connection': {
        'host': 'localhost',
        'user': process.env.DB_USER,
        'password': process.env.DB_PASS
    },
	'database': 'inmobiliariagolden',
    'users_table': 'asesores'
}