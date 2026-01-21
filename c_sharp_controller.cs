using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Mvc;
using JWT;

namespace Sample.Areas.Core.Controllers
{
    public class ConnectionController : Controller
    {
        // GET: Core/Connection
        public ActionResult Index(string return_to)
        {
            var t = (DateTime.UtcNow - new DateTime(1970, 1, 1));
            var timestamp = (int)t.TotalSeconds;

            var payload = new Dictionary<string, object> {
                { "iat", timestamp },
                { "jti", Guid.NewGuid().ToString() }
                // { "name", currentUser.name },
                // { "email", currentUser.email }
                // { "external_id", currentUesr.externalId }
                // { "locale", currentUesr.locale }
                // { "organization", currentUesr.organization }
                // { "organization_id", currentUesr.organizationId }
                // { "phone", currentUesr.phone }
                // { "tags", currentUesr.tags }
                // { "remote_photo_url", currentUesr.remotePhotoUrl }
                // { "role", currentUesr.role }
                // { "custom_role_id", currentUesr.customRoleId }
                // { "user_fields", currentUesr.userFields }
            };

            var token = JsonWebToken.Encode(payload, ConfigurationManager.AppSettings["ZENDESK_SHARED_KEY"], JwtHashAlgorithm.HS256);
            var redirectUrl = "https://" + ConfigurationManager.AppSettings["ZENDESK_SUBDOMAIN"] + ".zendesk.com/access/jwt?jwt=" + token;

            if (return_to != null)
            {
                redirectUrl += "&return_to=" + HttpUtility.UrlEncode(return_to);
            }

            return this.Redirect(redirectUrl);
        }
    }
}
