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
            var payload = new Dictionary<string, object>() {
                { "iat", (new DateTime()).ToLongTimeString() },
                { "jti", System.Guid.NewGuid() }
                // { "name", currentUser.name },
                // { "email", currentUser.email }
            };

            string token = JWT.JsonWebToken.Encode(payload, SHARED_KEY, JWT.JwtHashAlgorithm.HS256);
            string redirectUrl = "https://" + SUBDOMAIN + ".zendesk.com/access/jwt?jwt=" + token;

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
