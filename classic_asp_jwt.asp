<!--Get the JWT implementation from https://github.com/zendesk/classic_asp_jwt -->
<!--#include file="jwt.asp" -->
<%
Dim sKey, sSubdomain, dAttributes, sParameter

' Set your key and Zendesk account subdomain
sKey       = ""
sSubdomain = ""

Set dAttributes = Server.CreateObject("Scripting.Dictionary")

dAttributes.Add "jti", UniqueString
dAttributes.Add "iat", SecsSinceEpoch
dAttributes.Add "name", "Someone"
dAttributes.Add "email", "someone@example.com"

sParameter = JWTEncode(dAttributes, sKey)

sUrl = "https://" & sSubdomain & ".zendesk.com/access/jwt?jwt=" & sParameter

if not isempty(Request.QueryString("return_to")) then
  sURL = sURL & "&return_to=" & Server.URLEncode(Request.QueryString("return_to"))
end if

Response.redirect sUrl
%>
