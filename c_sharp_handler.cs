// Handler: <%@ WebHandler Language="C#" Class="Zendesk.JWTLogin" CodeBehind="Zendesk.JWTLogin.cs" %>
// Requires: JWT (https://nuget.org/packages/JWT)
// Tested with .NET 4.5

using System;
using System.Web;
using System.Collections.Generic;

namespace Zendesk
{
    public class JWTLogin : IHttpHandler
    {
        private const string SHARED_KEY = "{my zendesk token}";
        private const string SUBDOMAIN = "{my zendesk subdomain}";

        public void ProcessRequest(HttpContext context)
        {
            TimeSpan t = (DateTime.UtcNow - new DateTime(1970, 1, 1));
            int timestamp  = (int) t.TotalSeconds;

            var payload = new Dictionary<string, object>() {
                { "iat", timestamp },
                { "jti", System.Guid.NewGuid().ToString() }
                // { "name", currentUser.name },
                // { "email", currentUser.email }
            };

            string token = JWT.JsonWebToken.Encode(payload, SHARED_KEY, JWT.JwtHashAlgorithm.HS256);
            string redirectUrl = "https://" + SUBDOMAIN + ".zendesk.com/access/jwt?jwt=" + token;

            string returnTo = context.Request.QueryString["return_to"];

            if(return_to != null) {
              redirectUrl += "&return_to=" + HttpUtility.UrlEncode(returnTo);
            }

            context.Response.Redirect(redirectUrl);
        }

        public bool IsReusable
        {
            get
            {
                return true;
            }
        }
    }
}
