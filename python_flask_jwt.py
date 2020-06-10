# This example relies on you having installed PyJWT, `sudo easy_install PyJWT` - you can
# read more about this in the GitHub repository https://github.com/progrium/pyjwt
 
from flask import Flask, request, redirect
import time
import uuid
import jwt
import urllib


#init app
app = Flask(__name__)
# insert token here
app.config['SHARED_KEY'] = ''
# insert account prefix here (e.g. yoursite.zendesk.com)
app.config['SUBDOMAIN'] = 'yoursite'
 
@app.route('/zendesk-jwt')
def sso_redirector():
 
	payload = {
		"iat": int(time.time()),
		"jti": str(uuid.uuid1()),
		# populate these values from your data source
		"name": '',
		"email": ''
	}
 
	jwt_string = jwt.encode(payload, app.config['SHARED_KEY'])
	# for python 3.7 use 
	# sso_url = "https://" + app.config ['SUBDOMAIN'] + ".zendesk.com/access/jwt?jwt=" + jwt_string.decode('utf8')

	sso_url = "https://" + app.config ['SUBDOMAIN'] + ".zendesk.com/access/jwt?jwt=" + jwt_string
	return_to = request.args.get('return_to')

	if return_to is not None:
		# for python > 3.7 use
		# sso_url += "&return_to=" + urllib.parse.quote(return_to)
		sso_url += "&return_to=" + urllib.quote(return_to)

	return redirect(sso_url)
 
if __name__ == "__main__":
	app.run()
