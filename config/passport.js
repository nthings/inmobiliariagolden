// config/passport.js

// load all the things we need
var LocalStrategy   = require('passport-local').Strategy;

// load up the user model
var mysql = require('mysql');
var bcrypt = require('bcrypt-nodejs');
var dbconfig = require('./database');
var connection2 = mysql.createConnection(dbconfig.connection);

connection2.query('USE ' + dbconfig.database);
// expose this function to our app using module.exports
module.exports = function(passport) {

    // =========================================================================
    // passport session setup ==================================================
    // =========================================================================
    // required for persistent login sessions
    // passport needs ability to serialize and unserialize users out of session

    // used to serialize the user for the session
    passport.serializeUser(function(user, done) {
        done(null, user.idasesores);
    });

    // used to deserialize the user
    passport.deserializeUser(function(id, done) {
        connection2.query("SELECT * FROM asesores WHERE idasesores = ? ",[id], function(err, rows){
            done(err, rows[0]);
        });
    });

    // =========================================================================
    // LOCAL SIGNUP ============================================================
    // =========================================================================
    // we are using named strategies since we have one for login and one for signup
    // by default, if there was no name, it would just be called 'local'

/*    passport.use(
        'local-signup',
        new LocalStrategy({
            // by default, local strategy uses username and password, we will override with email
            usernameField : 'username',
            passwordField : 'password',
            passReqToCallback : true // allows us to pass back the entire request to the callback
        },
        function(req, username, password, done) {
            // find a user whose email is the same as the forms email
            // we are checking to see if the user trying to login already exists
            connection2.query("SELECT * FROM asesores WHERE username = ?",[username], function(err, rows) {
                if (err)
                    return done(err);
                if (rows.length) {
                    return done(null, false, req.flash('signupMessage', 'El nombre de usuario ya existe.'));
                } else {
                    // if there is no user with that username
                    // create the user
                    var newUserMysql = {
                        nombre: req.body.nombre,
                        telefono: req.body.telefono,
                        username: username,
                        password: bcrypt.hashSync(password, null, null),  // use the generateHash function in our user model
                        socio:req.body.socio
                    };

                    var insertQuery = "INSERT INTO asesores ( nombre, telefono, username, password, socio ) values (?,?,?,?,?)";

                    connection2.query(insertQuery,[newUserMysql.nombre, newUserMysql.telefono, newUserMysql.username, newUserMysql.password, newUserMysql.socio],function(err, rows) {
                        newUserMysql.idasesores = rows.insertId;
                        console.log(newUserMysql);

                        return done(null, newUserMysql);
                    });
                }
            });
        })
    );*/

    // =========================================================================
    // LOCAL LOGIN =============================================================
    // =========================================================================
    // we are using named strategies since we have one for login and one for signup
    // by default, if there was no name, it would just be called 'local'

    passport.use(
        'local-login',
        new LocalStrategy({
            // by default, local strategy uses username and password, we will override with email
            usernameField : 'username',
            passwordField : 'password',
            passReqToCallback : true // allows us to pass back the entire request to the callback
        },
        function(req, username, password, done) { // callback with email and password from our form
            connection2.query("SELECT * FROM asesores WHERE username = ?",[username], function(err, rows){
                if (err)
                    return done(err);
                if (!rows.length) {
                    return done(null, false, req.flash('loginMessage', 'Ese usuario no existe.')); // req.flash is the way to set flashdata using connect-flash
                }

                // if the user is found but the password is wrong
                if (!bcrypt.compareSync(password, rows[0].password)){
                    return done(null, false, req.flash('loginMessage', 'Oops! Esa no es tu contraseña.')); // create the loginMessage and save it to session as flashdata
                }

                // all is well, return successful user
                return done(null, rows[0]);
            });
        })
    );
};
