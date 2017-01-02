// app/routes.js
var multer  = require('multer')
var fs = require('fs');
var bcrypt = require('bcrypt-nodejs');
var Feed = require('feed');
var gm = require('gm').subClass({ imageMagick: true });
var phantom = require('phantom');   

var upload = multer({ 
    dest: 'assets/fotoscasas/',
    rename: function(fieldname, filename) {
        return filename;
    },
    onFileUploadStart: function(file) {
        if(file.mimetype !== 'image/jpg' && file.mimetype !== 'image/jpeg' && file.mimetype !== 'image/png') {
            return false;
        }
    } 
});
module.exports = function(app, passport, connection) {
    app.get("/", function(req, res) {
        connection.query('SELECT * FROM propiedades ORDER BY idpropiedades DESC', function(err, propiedades){
            connection.query('SELECT nombre, telefono, foto FROM asesores WHERE admin != 1',function(err, asesores){
                res.render('index.ejs', {
                    propiedades: propiedades,
                    asesores: asesores,
                });
            });
        });
    });

    app.post("/", function(req, res) {
        console.log(req.body);
        var extras="";
        var valores=[req.body.tipo];
        if(req.body.propiedad != "indistinto"){
            extras+=" AND tipo = ?";
            valores.push(req.body.propiedad);
        }
        if(req.body.recamaras != ""){
            extras+=" AND recamaras = ?";
            valores.push(req.body.recamaras);
        }
        if(req.body.baños != ""){
            extras+=" AND baños = ?";
            valores.push(req.body.baños);
        }
        if(req.body.cochera != ""){
            extras+=" AND cochera = ?";
            valores.push(req.body.cochera);
        }
        if(req.body.precio1 != ""){
            extras+=" AND precio >= ?";
            valores.push(req.body.precio1);
        }
        if(req.body.precio2 != ""){
            extras+=" AND precio <= ?";
            valores.push(req.body.precio2);
        }
        connection.query('SELECT * FROM propiedades WHERE renta = ?'+extras,valores, function(err, propiedades){
            connection.query('SELECT nombre, telefono, foto FROM asesores WHERE admin != 1',function(err, asesores){
                console.log(propiedades);
                res.render('index.ejs', {
                    propiedades: propiedades,
                    asesores: asesores,
                    eliminar: 1,
                });
            });
        });
    });

    app.get('/login', function(req,res) {
        res.render('login.ejs',{ message: req.flash('loginMessage') });
    });
    
    app.post('/login', passport.authenticate('local-login', {
        successRedirect : '/panel', // redirect to the secure profile section
        failureRedirect : '/login', // redirect back to the signup page if there is an error
        failureFlash : true // allow flash messages
    }));

    app.get("/propiedad",function(req,res) {
        connection.query('SELECT * FROM propiedades P, asesores A WHERE P.idpropiedades = ? AND A.idasesores=P.asesores_idasesores', [req.query.id], function(err, propiedad) {
            connection.query('SELECT * FROM fotos WHERE propiedades_idpropiedades=?',[req.query.id],function(err,fotos) {
              console.log(fotos);
              res.render('propiedad.ejs', {
                  propiedad: propiedad[0],
                  fotos: fotos,
              });  
          });
        });
    });

    app.get('/panel', inicioSesion, function(req, res) {
        connection.query('SELECT nombrepropiedad, idpropiedades,fechacreacion,url,asesores_idasesores FROM propiedades WHERE `vendida` = 0',function(err, propiedades){
            connection.query('SELECT nombrepropiedad, idpropiedades, fechaventa,url,asesores_idasesores FROM propiedades WHERE `vendida` = 1',function(err, propiedadesvendidas){
                connection.query('SELECT idasesores, nombre, foto FROM asesores WHERE admin != 1',function(err, asesores){
                    if (typeof(req.query.agregado) != 'undefined') {
                        if(req.query.agregado == "1"){
                            res.render('panel.ejs', {
                                propiedades: propiedades,
                                propiedadesvendidas: propiedadesvendidas,
                                asesores: asesores,
                                user : req.user,
                                titulomensaje: "¡Éxito!",
                                mensaje: "Agregado Con Éxito",
                            }); 
                        }else{
                            res.render('panel.ejs', {
                                propiedades: propiedades,
                                propiedadesvendidas: propiedadesvendidas,
                                asesores: asesores,
                                user : req.user,
                                titulomensaje: "¡ERROR!",
                                mensaje: "ERROR EN AGREGAR, INTENTALO DE NUEVO",
                            });
                        }
                    }else{
                        res.render('panel.ejs', {
                            propiedades: propiedades,
                            propiedadesvendidas: propiedadesvendidas,
                            asesores: asesores,
                            user : req.user,
                        });
                    }
                });
            });
        });
    });

    app.post('/agregarpropiedad',inicioSesion,upload.array('image'), function(req, res) {
        /*Agregar propiedad*/
        var ventaorenta = 0;
        if(req.body.ventaorenta != 0){
            ventaorenta = 1;
        }
        var fecha = new Date().toISOString().substring(0, 10);

        /*Subir foto*/
        console.log(req.files);
        console.log(req.body);
        if(typeof(req.files) != 'undefined' && req.files.length > 0){
            connection.query('INSERT INTO propiedades (tipo, nombrepropiedad, precio, m2, recamaras, baños, cochera, descripcion, direccion, latitud, longitud, renta, vendida, fechaventa,fechacreacion, url, asesores_idasesores) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',[req.body.tipo, req.body.nombrepropiedad,req.body.precio,req.body.m2,req.body.recamaras,req.body.baños,req.body.cochera,req.body.descripcion,req.body.direccion,req.body.latitud,req.body.longitud,ventaorenta,0,null,fecha,'/fotoscasas/'+req.files[0].filename,req.user.idasesores], function(err, result){
                if (err) {
                    console.log(err);
                    res.redirect('/panel?agregado=0');
                }else{
                    for(var i=1;i < req.files.length;i++){
                        console.log("i: "+i+"files: "+req.files.length+"length-1: "+(req.files.length-1));
                        connection.query('INSERT INTO fotos (url, propiedades_idpropiedades) VALUES(?,?)',['/fotoscasas/'+req.files[i].filename,result.insertId],function(err,result2) {
                            if(err){
                                console.log(err);
                                res.redirect('/panel?agregado=0');
                            }
                        });
                    }
                }
            });        
        }else{
            /*NO HAY IMAGEN PRINCIPAL*/
            connection.query('INSERT INTO propiedades (tipo, nombrepropiedad, precio, m2, recamaras, baños, cochera, descripcion, direccion, latitud, longitud, renta, vendida, fechaventa,fechacreacion, asesores_idasesores) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',[req.body.tipo, req.body.nombrepropiedad,req.body.precio,req.body.m2,req.body.recamaras,req.body.baños,req.body.cochera,req.body.descripcion,req.body.direccion,req.body.latitud,req.body.longitud,ventaorenta,0,null,fecha,req.user.idasesores], function(err, result){
                if (err) {
                    console.log(err);
                    res.redirect('/panel?agregado=0');
                }
            });
        }
        res.redirect('/panel?agregado=1');
    });

    app.get('/vendida',inicioSesion,function(req, res) {
        var fecha = new Date().toISOString().substring(0, 10);
        connection.query('UPDATE propiedades SET vendida = 1, fechaventa = ? WHERE idpropiedades = ?',[fecha, req.query.id], function(err, result){
            if (err) {
                console.log(err);
            }
            res.redirect('/panel');
        });
    });

    app.get('/deshacervendida',inicioSesion,function(req, res) {
        connection.query('UPDATE propiedades SET vendida = 0 WHERE idpropiedades = ?',[req.query.id], function(err, result){
            if (err) {
                console.log(err);
            }
            res.redirect('/panel');
        });
    });

    app.post('/eliminarpropiedad',inicioSesion,function(req, res) {
        connection.query('SELECT url FROM propiedades WHERE idpropiedades = ?',[req.body.id], function(err, result){
            console.log(result);
            if(result[0].url != "../picture.png"){
                fs.unlink("assets"+result[0].url,function(err) {
                    console.log(err);
                });   
            }
            connection.query('SELECT url FROM fotos WHERE propiedades_idpropiedades = ?',[req.body.id], function(err, fotos){
                fotos.forEach(function(foto){
                    if(foto.url != "../picture.png"){
                        fs.unlink("assets"+foto.url,function(err) {
                            console.log(err);
                        });   
                    }
                });
                connection.query('DELETE FROM fotos WHERE propiedades_idpropiedades = ?',[req.body.id], function(err, result){
                    if (err) {
                        console.log(err);
                        res.redirect('/panel');
                    }
                    connection.query('DELETE FROM propiedades WHERE idpropiedades = ?',[req.body.id], function(err, result){
                        if (err) {
                            console.log(err);
                            res.redirect('/panel');
                        }
                        res.redirect('/panel');
                    });
                });
            });
        });
    });

    app.get('/editarpropiedad',inicioSesion,function(req, res) {
        connection.query('SELECT * FROM propiedades WHERE idpropiedades = ?',[req.query.id], function(err, propiedad){
            connection.query('SELECT * FROM fotos WHERE propiedades_idpropiedades = ?',[req.query.id], function(err, fotos){
                console.log(propiedad);
                if (typeof(req.query.cambio) != 'undefined') {
                    if(req.query.cambio == "1"){
                        res.render('editarpropiedad.ejs', {
                            propiedad: propiedad[0],
                            fotos:fotos,
                            user : req.user,
                            titulomensaje: "¡Éxito!",
                            mensaje: "Editado Con Éxito",
                        }); 
                    }else{
                        res.render('editarpropiedad.ejs', {
                            propiedad: propiedad[0],
                            fotos:fotos,
                            user : req.user,
                            titulomensaje: "¡Error!",
                            mensaje: "Ocurrió Un Error",
                        });
                    }
                }else{
                    res.render('editarpropiedad.ejs', {
                        propiedad: propiedad[0],
                        fotos:fotos,
                        user : req.user,
                    });
                }
            });      
        });
    });

    app.get('/verpropiedad',inicioSesion,function(req, res) {
        connection.query('SELECT * FROM propiedades WHERE idpropiedades = ?',[req.query.id], function(err, propiedad){
            connection.query('SELECT * FROM fotos WHERE propiedades_idpropiedades = ?',[req.query.id], function(err, fotos){
            
                res.render('verpropiedad.ejs', {
                    propiedad: propiedad[0],
                    fotos:fotos,
                    user : req.user,
                });
            });      
        });
    });

    var cpUpload = upload.fields([{ name: 'principal'}, { name: 'image'}, { name: 'nuevas'}])
    app.post('/editarpropiedad',inicioSesion,cpUpload,function(req, res) {
        console.log(req.body);
        console.log(req.files);
        var ventaorenta = 0;
        if(req.body.ventaorenta != 0){
            ventaorenta = 1;
        }
        function fotosNuevas() {
            // body...
            if(typeof(req.files['nuevas']) != 'undefined'){
                for (var i = 0; i < req.files['nuevas'].length; i++) {
                    connection.query('INSERT INTO fotos (url, propiedades_idpropiedades) VALUES(?,?)',['/fotoscasas/'+req.files['nuevas'][i].filename,req.body.id],function(err,result) {
                        console.log("NUEVA IMAGEN AGREGADA");
                    });
                }
                res.redirect('/editarpropiedad?id='+req.body.id+'&cambio=1');
            }else{
                res.redirect('/editarpropiedad?id='+req.body.id+'&cambio=1');
            }
        }
        /*No se cambio la foto principal*/
        if(typeof(req.files['principal']) == 'undefined'){
            connection.query('UPDATE propiedades SET tipo = ?, nombrepropiedad = ?, precio = ?, m2 = ?, recamaras = ?, baños = ?, cochera=?, descripcion = ?, direccion = ?, latitud = ?, longitud = ?, renta = ? WHERE idpropiedades = ?',[req.body.tipo, req.body.nombrepropiedad, req.body.precio, req.body.m2, req.body.recamaras, req.body.baños, req.body.cochera, req.body.descripcion, req.body.direccion, req.body.latitud, req.body.longitud, ventaorenta, req.body.id], function(err, result){
                console.log(err);
                if(typeof(req.files['image']) != 'undefined'){
                    connection.query('SELECT url FROM fotos WHERE propiedades_idpropiedades = ?',[req.body.id], function(err, fotos){
                        console.log(err);
                        if(typeof(fotos) != 'undefined'){
                            /*Reemplazar fotos*/
                            var a = 0;
                            for (var i = 0; i < req.body.fotos.length; i++) {
                                if(req.body.fotos[i]!=''){
                                    fs.unlink("assets"+fotos[i].url,function(err) {
                                        console.log(err);
                                    });   
                                    connection.query('UPDATE fotos SET url = ? WHERE url = ?',['/fotoscasas/'+req.files['image'][a].filename,fotos[i].url], function(err, result){
                                        console.log("updated"); 
                                    });
                                    a++;
                                }
                            }
                            fotosNuevas();
                        }else{
                            fotosNuevas();
                        }
                    }); 
                }else{
                    fotosNuevas();
                }
            });
        }else{
            /*Cambio la foto principal*/
            connection.query('SELECT url FROM propiedades WHERE idpropiedades = ?',[req.body.id], function(err, foto){
                if(foto[0].url != "../picture.png"){
                    fs.unlinkSync("assets"+foto[0].url);
                }
                connection.query('UPDATE propiedades SET tipo = ?, nombrepropiedad = ?, precio = ?, m2 = ?, recamaras = ?, baños = ?, cochera = ?, descripcion = ?, direccion = ?, latitud = ?, longitud = ?, renta = ?, url = ? WHERE idpropiedades = ?',[req.body.tipo, req.body.nombrepropiedad, req.body.precio, req.body.m2, req.body.recamaras, req.body.baños, req.body.cochera,req.body.descripcion, req.body.direccion, req.body.latitud, req.body.longitud, ventaorenta, '/fotoscasas/'+req.files['principal'][0].filename, req.body.id], function(err, result){
                    console.log(err);
                    if(typeof(req.files['image']) != 'undefined'){
                        connection.query('SELECT url FROM fotos WHERE propiedades_idpropiedades = ?',[req.body.id], function(err, fotos){
                            console.log(err);
                            if(typeof(fotos) != 'undefined'){
                                /*Reemplazar fotos*/
                                var a = 0;
                                for (var i = 0; i < req.body.fotos.length; i++) {
                                    if(req.body.fotos[i]!=''){
                                        fs.unlink("assets"+fotos[i].url,function(err) {
                                            console.log(err);
                                        });   
                                        connection.query('UPDATE fotos SET url = ? WHERE url = ?',['/fotoscasas/'+req.files['image'][a].filename,fotos[i].url], function(err, result){
                                            console.log("updated"); 
                                        });
                                        a++;
                                    }
                                }
                                fotosNuevas();
                            }else{
                                fotosNuevas();
                            }
                        }); 
                    }else{
                        fotosNuevas();
                    }
                });
            });
        }
    });

app.post('/eliminarfoto',inicioSesion, function(req, res) {
    connection.query('DELETE FROM fotos WHERE url = ?',[req.body.fotourl], function(err, result){
        fs.unlink("assets"+req.body.fotourl,function(err) {
            console.log(err);
            res.redirect('/editarpropiedad?id='+req.body.id+'&cambio=1');
        });   
    });
});

app.post('/agregarasesor',inicioSesion,upload.single('image'), function(req, res) {
    console.log(req.file);
    connection.query("SELECT * FROM asesores WHERE username = ?",[req.body.username], function(err, rows) {
        if (err)
            res.redirect('/panel?agregado=0');
        if (rows.length) {
            /*Existe ese usuario*/
            res.redirect('/panel?agregado=0');
        } else {
            if(typeof(req.file) == 'undefined'){
                var insertQuery = "INSERT INTO asesores ( nombre, telefono, username, password, socio) values (?,?,?,?,?)";
                connection.query(insertQuery,[req.body.nombre, req.body.telefono, req.body.username, bcrypt.hashSync(req.body.password, null, null), req.body.socio],function(err, rows) {
                    res.redirect('/panel?agregado=1');
                });
            }else{
                var insertQuery = "INSERT INTO asesores ( nombre, telefono, username, password, socio, foto ) values (?,?,?,?,?,?)";
                connection.query(insertQuery,[req.body.nombre, req.body.telefono, req.body.username, bcrypt.hashSync(req.body.password, null, null), req.body.socio, '/fotoscasas/'+req.file.filename],function(err, rows) {
                    res.redirect('/panel?agregado=1');
                });
            }
        }
    });
});

app.get('/editarasesor',inicioSesion, function(req, res) {
    connection.query('SELECT * FROM asesores WHERE idasesores = ?',[req.user.idasesores],function(err, asesor){
        res.render('editarasesor.ejs',{
            asesor: asesor[0],
            user : req.user,
        });
    });

});

app.post('/editarasesor',inicioSesion,upload.single('image'), function(req, res) {
    if(typeof(req.file) != 'undefined'){
        /*Cambio su foto*/
        connection.query('UPDATE asesores SET nombre = ?, telefono = ?, username = ?, password = ?, foto = ? WHERE idasesores = ? ',[req.body.nombre, req.body.telefono, req.body.username, bcrypt.hashSync(req.body.password, null, null), '/fotoscasas/'+req.file.filename,req.user.idasesores], function(err, result){
            res.redirect('/editarasesor');
        });
    }else{
        /*No cambio su foto*/
        connection.query('UPDATE asesores SET nombre = ?, telefono = ?, username = ?, password = ? WHERE idasesores = ? ',[req.body.nombre, req.body.telefono, req.body.username, bcrypt.hashSync(req.body.password, null, null), req.user.idasesores], function(err, result){
            res.redirect('/editarasesor');
        });
    }
});

app.post('/eliminarasesor',inicioSesion, function(req, res) {
    connection.query('UPDATE propiedades SET asesores_idasesores = ? WHERE asesores_idasesores = ? ',[req.body.asesor, req.body.id], function(err, result){
        connection.query('SELECT foto FROM asesores WHERE idasesores = ?',[req.body.id], function(err, foto){
            connection.query('DELETE FROM asesores WHERE idasesores = ?',[req.body.id], function(err, result){
                if(foto[0].foto != "../picture.png"){
                    fs.unlink("assets"+foto[0].foto,function(err) {
                        console.log(err);
                        res.redirect('/panel');
                    });   
                }else{
                    res.redirect('/panel');
                }
            });  
        });
    });
});

app.get('/rss', function(req, res) {

        // Initializing feed object
        var feed = new Feed({
            title:          'Golden',
            description:    'Propiedades',
            link:           'http://goldenagenciainmobiliaria.com/',
            image:          'http://goldenagenciainmobiliaria.com/logoup.png',
            copyright:      'Copyright © 2016 Golden. All rights reserved',
            author: {
                name:       'Golden',
            }
        });

        // Function requesting the last 5 posts to a database. This is just an
        // example, use the way you prefer to get your posts.   
        connection.query('SELECT * FROM propiedades', function(err, propiedades){
            propiedades.forEach(function(propiedad) {
                feed.item({
                    title:          propiedad.nombrepropiedad,
                    link:           'http://goldenagenciainmobiliaria.com/propiedad/?id='+propiedad.idpropiedades,
                    description:    propiedad.descripcion,
                    date:           propiedad.fechacreacion,
                });
            });
            // Setting the appropriate Content-Type
            res.set('Content-Type', 'text/xml');

            // Sending the feed as a response
            res.send(feed.render('rss-2.0'));
        });

    });

// Calendario de citas
app.get('/citas',inicioSesion, function(req, res) {
    connection.query('SELECT idcita,titulo, DATE_FORMAT(inicio, "%Y-%m-%d %H:%i:%s") as inicio, DATE_FORMAT(fin, "%Y-%m-%d %H:%i:%s") as fin, asesores_idasesores FROM citas', function(err, citas){
        res.render('citas.ejs',{
            citas: citas,
            user : req.user,
        });
    });  
});

app.post('/citas', inicioSesion, function(req, res) {
        console.log(req.body);
    connection.query('INSERT INTO citas (titulo, inicio,fin,asesores_idasesores) VALUES(?,?,?,?)',[req.body.titulo, req.body.inicio, req.body.fin, req.user.idasesores], function(err, citas){
        console.log(err);
        res.redirect('/citas');
    }); 
});

app.get('/logout', function(req, res) {
    req.logout();
    res.redirect('/');
});
};

// route middleware to make sure a user is logged in
function inicioSesion(req, res, next) {

    // if user is authenticated in the session, carry on 
    if (req.isAuthenticated())
        return next();

    // if they aren't redirect them to the home page
    res.redirect('/login');
}