// Handler: <%@ WebHandler Language="C#" Class="Zendesk.JWTLogin" CodeBehind="Zendesk.JWTLogin.cs" %>
// Requires: JWT (https://nuget.org/packages/JWT)
// Tested with .NET 4.5

using System;
using System.Collections.Generic;
using JWT;

namespace Zendesk
{
    public class SSO
    {
        // Ensure environment variable is set correctly and fetch here
        private static readonly string SHARED_KEY = "{my Zendesk token}";

        public string Generate(string name, string email)
        {
            TimeSpan t = (DateTime.UtcNow - new DateTime(1970, 1, 1));
            int timestamp = (int)t.TotalSeconds;

            var payload = new Dictionary<string, object>() {
                { "iat", timestamp },
                { "jti", System.Guid.NewGuid().ToString() },
                { "name", name },
                { "email", email }
            };

            string token = JWT.JsonWebToken.Encode(payload, SHARED_KEY, JWT.JwtHashAlgorithm.HS256);
            return token;
        }
    }
}
