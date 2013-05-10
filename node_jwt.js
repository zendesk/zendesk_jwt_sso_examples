// requires jwt-simple, uuid
// install with: npm install jwt-simple uuid
// or from: https://github.com/hokaccha/node-jwt-simple and https://github.com/broofa/node-uuid

var http = require('http');
var jwt = require('jwt-simple');
var uuid = require('uuid');

var subdomain = '{my zendesk subdomain}';
var shared_key = '{my zendesk token}';

http.createServer(function (request, response) {
  var payload = {
    iat: (new Date().getTime() / 1000),
    jti: uuid.v4()
    // name: user.name(),
    // email: user.email()
  };

  // encode
  var token = jwt.encode(payload, shared_key);

  response.writeHead(302, {
    'Location': 'https://' + subdomain + '.zendesk.com/access/jwt?jwt=' + token
  });
  response.end();
}).listen(8124);

console.log('Server running at http://127.0.0.1:8124/');

