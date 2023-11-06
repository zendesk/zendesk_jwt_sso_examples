# This example relies on you having install PyJWT, `sudo easy_install PyJWT` - you can
# read more about this in the GitHub repository https://github.com/progrium/pyjwt

import os
import time
import jwt
import uuid

# ensure your Zendesk shared key secret is set
SHARED_KEY = os.environ.get('SHARED_KEY')

def generate_jwt(name, email):
  payload = {
    "iat": int(time.time()),
    "jti": str(uuid.uuid1()),
    "name": name,
    "email": email
  }

  return jwt.encode(payload, SHARED_KEY, algorithm="HS256", headers={"typ": "JWT"})
