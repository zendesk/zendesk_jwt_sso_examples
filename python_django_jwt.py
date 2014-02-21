# This example relies on you having install PyJWT, `sudo easy_install PyJWT` - you can
# read more about this in the GitHub repository https://github.com/progrium/pyjwt

from django.http import HttpResponseRedirect

import time
import jwt
import uuid
import urllib

def index(request):

  payload = {
    "iat": int(time.time()),
    "jti": str(uuid.uuid1()),
    "name": request.user.get_full_name(),
    "email": request.user.email
  }

  subdomain  = "{my zendesk subdomain}"
  shared_key = "{my zendesk token}"
  jwt_string = jwt.encode(payload, shared_key)
  location = "https://" + subdomain + ".zendesk.com/access/jwt?jwt=" + jwt_string
  return_to = request.GET.get('return_to')

  if return_to is not None:
    location += "&return_to=" + urllib.quote(return_to)

  return HttpResponseRedirect(location)
