const http = require('http');
const fs = require('fs');
const ip = require('ip');
const port = 9999;


var server = http.createServer(function (req, res) {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end("This is my IP: " + ip.address() + '\n');

    res.end("Secret found');

});

server.listen(port);
console.log('Server running on port ' + port);

