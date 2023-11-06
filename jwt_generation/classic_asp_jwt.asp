<!--Get the JWT implementation from https://github.com/zendesk/classic_asp_jwt -->
<!--#include file="jwt.asp" -->
<%
Dim sKey, dAttributes, sParameter

' Set your key
sKey = Request.ServerVariables("SHARED_ZENDESK_KEY")

Set dAttributes = Server.CreateObject("Scripting.Dictionary")

dAttributes.Add "jti", UniqueString
dAttributes.Add "iat", SecsSinceEpoch
dAttributes.Add "name", "Someone"
dAttributes.Add "email", "someone@example.com"

sParameter = JWTEncode(dAttributes, sKey)

Response.Write(sParameter)
%>
