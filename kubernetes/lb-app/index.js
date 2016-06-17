const http = require('http');
const fs = require('fs');
const ip = require('ip');
const port = 9999;


var server = http.createServer(function (req, res) {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');

    var message = "LB Application - version :"  + process.env.VERSION + '\n'
                  "-- This is my IP: " + ip.address() + '\n';

    if (process.env.LBAPP_DB_PWD && process.env.LBAPP_DB_USER) {
        message += "-- Secret found!' username: " + process.env.LBAPP_DB_USER + "; password: " + process.env.LBAPP_DB_PWD;
    }
    res.end(message);

});

server.listen(port);
console.log(process.env);
console.log('Server running on port ' + port);

