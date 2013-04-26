# This example relies on you having install PyJWT, `sudo easy_install PyJWT` - you can
# read more about this in the GitHub repository https://github.com/progrium/pyjwt

from django.http import HttpResponseRedirect

import time
import jwt
import uuid

def index(request):
  now = int(time.time())

  payload = {
    "iat": int(time.time()),
    "jti": str(uuid.uuid1()),
    "name": user.name,
    "email": user.email
  }

  subdomain  = "{my zendesk subdomain}"
  shared_key = "{my zendesk token}"
  jwt_string = jwt.encode(payload, shared_key)
  return HttpResponseRedirect("https://" + subdomain + ".zendesk.com/access/jwt?jwt=" + jwt_string)
