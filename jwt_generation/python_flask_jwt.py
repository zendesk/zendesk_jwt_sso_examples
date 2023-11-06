# This example relies on you having installed PyJWT, `sudo easy_install PyJWT` - you can
# read more about this in the GitHub repository https://github.com/progrium/pyjwt
 
from flask import Flask
import time
import uuid
import jwt
 
# ensure your Zendesk shared key secret is set
app.config['SHARED_KEY']
 
def generate_jwt(name, email):
	payload = {
		"iat": int(time.time()),
		"jti": str(uuid.uuid1()),
		"name": name,
		"email": email
	}
 
	return jwt.encode(payload, app.config['SHARED_KEY'], algorithm="HS256", headers={"typ": "JWT"})
