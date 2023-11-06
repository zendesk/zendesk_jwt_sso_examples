// requires jwt-simple, uuid
// install with: npm install jwt-simple uuid
// or from: https://github.com/hokaccha/node-jwt-simple and https://github.com/broofa/node-uuid

const jwt = require('jwt-simple');
const uuid = require('uuid');

// Access your shared key via an environment variable
const shared_key = process.env.SHARED_KEY;

function generateJwt(name, email) {
  const payload = {
    iat: Math.floor(new Date().getTime() / 1000),
    jti: uuid.v4(),
    name: name,
    email: email
  };

  // encode
  return jwt.encode(payload, shared_key);
}

