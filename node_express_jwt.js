// requires express, cors
// install with: npm install express cors jwt-simple uuid
const express = require('express');
var cors = require('cors')
const jwt = require('jwt-simple');
const uuid = require('uuid');

const app = express()
const PORT = 8124;

app.use(cors())
app.use(express.json());

app.get('/', (req, res) => {
  const subdomain = '{my zendesk subdomain}';
  const shared_key = '{my zendesk shared token}';

  const payload = {
    iat: (new Date().getTime() / 1000),
    jti: uuid.v4(),
    // name: '[User name that exists on Zendesk]',
    // email: '[User email that exists on Zendesk]',
  };

  const { query } = req;
  const token = jwt.encode(payload, shared_key);
  let redirect = `https://${subdomain}.zendesk.com/access/jwt?jwt=${token}`;

  if(query['return_to']) {
    redirect += `&return_to=${encodeURIComponent(query['return_to'])}`;
  }

  res.redirect(302, redirect);
});

app.listen(PORT, () => console.log(`The server is running port ${PORT}...`));
