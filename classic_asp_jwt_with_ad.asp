<!--#include file="jwt.asp" -->
<%
    Dim sKey, sSubdomain, sLdapReaderUsername, sLdapReaderPassword, sLoginErrorMessage
    Dim dAttributes, sParameter, sRedirectUrl, sExternalIdField, sOrganizationField, sTagsField, sPhotoUrlField

    ' This script relies on the classic ASP implementation from https://github.com/zendesk/classic_asp_jwt
    ' Once you have that in place, proceed to configure the script as instructed in the documentation below
    '
    ' 1. Place this script in a folder on your IIS, and disable anonymous access for the script.
    ' 2. Add a valid user/password for the LDAP lookups by setting the variables sLdapReaderUsername
    '    and sLdapReaderPassword below.
    '
    ' Please note that the ISS does not have to be in the DMZ or in any way accessible via the internet,
    ' as the authentication is driven via browser redirects.
    '
    ' Please refer to https://support.zendesk.com/entries/23675367 for an in depth explanation on how
    ' remote authentication with JWT works.

    ' Set your shared secret and Zendesk subdomain
    sKey       = ""
    sSubdomain = ""

    ' Credentials for a domain user for LDAP access
    sLdapReaderUsername = ""
    sLdapReaderPassword = ""

    ' The below 4 fields can optionally be sent to Zendesk. In order to do so, set each variable to the field
    ' name on the local user record. E.g. sExternalIdField = "sAMAccountName" and so forth.
    sExternalIdField    = ""
    sOrganizationField  = ""
    sTagsField          = ""
    sPhotoUrlField      = ""
    

    ' Debug Mode Switch
    ' Set this to True to turn on Debug Mode. Set it to False to use in production.

    Dim dM
    dM = False

    Set dAttributes = GetAuthenticatedUser()

    If dAttributes Is Nothing Then
      If dM Then
        Response.Write("Could not login to Zendesk. Please contact your administrator.")
        Response.Write("Account '" & Request.ServerVariables("LOGON_USER") & "' not found.")

        Debug "Account '" & Request.ServerVariables("LOGON_USER") & "' not found."
      Else
        Response.Status = "401 Unauthorized"
      End If
    ElseIf dAttributes("email") = "" Then
      If dM Then
        Response.Write("Could not login to Zendesk. Please contact your administrator.")
        Response.Write("User '" & Request.ServerVariables("LOGON_USER") & "' has no email.")

        Debug "User '" & Request.ServerVariables("LOGON_USER") & "' has no email."
      Else
        Response.Write("User does not have an email address.")
      End If
    Else
      sParameter   = JWTTokenForUser(dAttributes)
      sRedirectUrl = "https://" & sSubdomain & ".zendesk.com/access/jwt?jwt=" & sParameter

      If dM Then
        Debug "Redirecting to " & sRedirectUrl
      Else
        Response.redirect sRedirectUrl
      End If
    End If
%>

<%
Function JWTTokenForUser(dAttributes)
  dAttributes.Add "jti", UniqueString
  dAttributes.Add "iat", SecsSinceEpoch

  If Not isempty(Request.QueryString("return_to")) Then
    dAttributes.Add "return_to", Request.QueryString("return_to")
  End If

  Dim i, aKeys
  aKeys = dAttributes.keys

  'For i = 0 To aKeys.Count-1
    'Debug("Attribute " & aKeys(i) & ": " & dAttributes(aKeys(i)))
  'Next

  JWTTokenForUser = JWTEncode(dAttributes, sKey)
End Function

Function Debug(sMessage)
  If request.QueryString("debug") = "1" Then
    response.Write("[DEBUG] " & sMessage & "<br/>")
  End If
End Function

Function GetAuthenticatedUser()
  Dim sDomainContainer, sUsername, sFields

  ' Retrieve authenticated user
  sUsername = split(Request.ServerVariables("LOGON_USER"),"\")(1)
  Debug Request.ServerVariables("LOGON_USER") & " - should be of the form DOMAIN\username - if blank, your IIS probably allows anonymous access to this file."

  Set rootDSE = GetObject("LDAP://RootDSE")
  Set oConn   = CreateObject("ADODB.Connection")

  sDomainContainer = rootDSE.Get("defaultNamingContext")
  Debug "DomainContainer: " & sDomainContainer

  oConn.Provider = "ADSDSOObject"
  oConn.properties("user id")  = sLdapReaderUsername
  oConn.properties("password") = sLdapReaderPassword
  oConn.Open "ADs Provider"

  sFields = "mail,displayName"

  If sExternalIdField > "" Then
    sFields = sFields & "," & sExternalIdField
  End If

  If sOrganizationField > "" Then
    sFields = sFields & "," & sOrganizationField
  End If

  If sTagsField > "" Then
    sFields = sFields & "," & sTagsField
  End If

  If sPhotoUrlField > "" Then
    sFields = sFields & "," & sPhotoUrlField
  End If

  sQuery  = "<LDAP://" & sDomainContainer & ">;(sAMAccountName=" & sUsername & ");adspath," & sFields & ";subtree"
  Set userRS = oConn.Execute(sQuery)

  If Not userRS.EOF and not err then
    Set dAttributes = Server.CreateObject("Scripting.Dictionary")

    dAttributes.Add "name", userRS("displayName").Value
    dAttributes.Add "email", userRS("mail").Value

    If sExternalIdField > "" Then
      dAttributes.Add "external_id", userRS(sExternalIdField).Value
    End If

    If sOrganizationField > "" Then
      dAttributes.Add "organization", userRS(sOrganizationField).Value
    End If

    If sTagsField > "" Then
      dAttributes.Add "tags", userRS(sTagsField).Value
    End If

    If sPhotoUrlField > "" Then
      dAttributes.Add "remote_photo_url", userRS(sPhotoUrlField).Value
    End If

    Set GetAuthenticatedUser = dAttributes
  else
    Set GetAuthenticatedUser = Nothing
  end if

  userRS.Close
  oConn.Close
End Function
%>
