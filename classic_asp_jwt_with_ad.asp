<!--#include file="jwt.asp" -->
<%
    Dim sKey, sSubdomain, sLdapReaderUsername, sLdapReaderPassword, sLoginErrorMessage
    Dim dAttributes, sParameter, sRedirectUrl, sExternalIdField, sOrganizationField, sTagsField
	Dim sPhotoURLField, sPhoneField, sRoleField, sCustomRoleIDField, sLocaleField, sLocaleIDField
	Dim dUserFields, sUserFieldKey1, sUserFieldValue1, sUserFieldKey2, sUserFieldValue2

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

    ' The below fields can OPTIONALLY be sent to Zendesk. In order to do so, set each variable to the field
    ' name on the local user record. E.g. sExternalIdField = "sAMAccountName" and so forth.
    sExternalIdField    = ""
    sOrganizationField  = ""
    sTagsField          = ""
    sPhotoUrlField      = ""
    sPhoneField         = ""
    sRoleField          = ""

    ' If the sRoleField is set to 'agent', you can specify a custom role ID (Enterprise only) with the below field
    sCustomRoleIDField  = ""

    ' Use sLocaleField for end-users, and sLocaleIDField.  Must be a valid integer from the available locales in your Zendesk.  
    ' For a list of valid locales and localeIDs, see: http://developer.zendesk.com/documentation/rest_api/locales.html 
    sLocaleField        = ""
    sLocaleIDField      = ""

    ' To use custom user fields, specify the 'Field key' value from Zendesk with sUserFieldKey#, and set sUserFieldValue# 
    ' to the field name on the local user record.  For more info, see: https://support.zendesk.com/entries/24740352
    ' To add additional custom user fields, add additional entries here as well as both commented areas in GetAuthenticatedUser()
    sUserFieldKey1		= ""
    sUserFieldValue1	= ""
    sUserFieldKey2		= ""
    sUserFieldValue2	= ""

    ' Debug Mode Switch
    ' Set this to True to turn on Debug Mode. Set it to False to use in production.
    Dim dM
    dM = False

    Set dAttributes = GetAuthenticatedUser()

    If dAttributes Is Nothing Then
      Response.Write("Could not login to Zendesk. Please contact your administrator.")
      Debug "Account '" & Request.ServerVariables("LOGON_USER") & "' not found."
    ElseIf dAttributes("email") = "" Then
      Response.write("Could not login to Zendesk. Please contact your administrator.")
      Debug "User '" & Request.ServerVariables("LOGON_USER") & "' has no email."
    Else
      sParameter   = JWTTokenForUser(dAttributes, dUserFields)
      sRedirectUrl = "https://" & sSubdomain & ".zendesk.com/access/jwt?jwt=" & sParameter
      If dM Then
        Debug "Redirecting to " & sRedirectUrl
      Else
        Response.redirect sRedirectUrl
      End If
    End If
%>

<%
Function JWTTokenForUser(dAttributes, dUserFields)
  dAttributes.Add "jti", UniqueString
  dAttributes.Add "iat", SecsSinceEpoch

  If Not isempty(Request.QueryString("return_to")) Then
    dAttributes.Add "return_to", Request.QueryString("return_to")
  End If

  Dim i, aAttributeKeys, aUserFieldKeys
  aAttributeKeys = dAttributes.keys

  For i = 0 To dAttributes.Count-1
    Debug("Attribute " & aAttributeKeys(i) & ": " & dAttributes(aAttributeKeys(i)))
  Next

  If dUserFields.Count = 0 Then
  Debug("'user_fields' not in use")
  Else
    aUserFieldKeys = dUserFields.keys
  For i = 0 to dUserFields.Count-1
    Debug("Custom User Field " & aUserFieldKeys(i) & ": " & dUserFields(aUserFieldKeys(i)))
  Next
  End If

  JWTTokenForUser = JWTEncode(dAttributes, dUserFields, sKey)
End Function

Function Encode_UTF8(astr)
  
  utftext = ""
  
  For n = 1 To Len(astr)
  c = AscW(Mid(astr, n, 1))
  If c < 128 Then
  utftext = utftext + Mid(astr, n, 1)
  ElseIf ((c > 127) And (c < 2048)) Then
  utftext = utftext + Chr(((c \ 64) Or 192))
  '((c>>6)|192);
  utftext = utftext + Chr(((c And 63) Or 128))
  '((c&63)|128);}
  Else
  utftext = utftext + Chr(((c \ 144) Or 234))
  '((c>>12)|224);
  utftext = utftext + Chr((((c \ 64) And 63) Or 128))
  '(((c>>6)&63)|128);
  utftext = utftext + Chr(((c And 63) Or 128))
  '((c&63)|128);
  End If
  Next

  Encode_UTF8 = utftext
End Function

Function Debug(sMessage)
  If dM Then
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
  
  If sPhoneField > "" Then
    sFields = sFields & "," & sPhoneField
  End If
  
  If sRoleField > "" Then
    sFields = sFields & "," & sRoleField
  End If
  
  If sCustomRoleIDField > "" Then
    sFields = sFields & "," & sCustomRoleIDField
  End If

  If sLocaleField > "" Then
    sFields = sFields & "," & sLocaleField
  End If
  
  If sLocaleIDField > "" Then
    sFields = sFields & "," & sLocaleIDField
  End If
  
 ' If you need more custom user fields, add additional entries below as well as above in the settings.
   If sUserFieldValue1 > "" Then
    sFields = sFields & "," & sUserFieldValue1
  End If
  
   If sUserFieldValue2 > "" Then
    sFields = sFields & "," & sUserFieldValue2
  End If  
  
  sQuery  = "<LDAP://" & sDomainContainer & ">;(sAMAccountName=" & sUsername & ");adspath," & sFields & ";subtree"
  Set userRS = oConn.Execute(sQuery)

  If Not userRS.EOF and not err then
    Set dAttributes = Server.CreateObject("Scripting.Dictionary")
  Set dUserFields = Server.CreateObject("Scripting.Dictionary")

    dAttributes.Add "name", Encode_UTF8(userRS("displayName").Value)
    dAttributes.Add "email", userRS("mail").Value

    If sExternalIdField > "" Then
      dAttributes.Add "external_id", userRS(sExternalIdField).Value
    End If

    If sOrganizationField > "" Then
      dAttributes.Add "organization", Encode_UTF8(userRS(sOrganizationField).Value)
    End If

    If sTagsField > "" Then
      dAttributes.Add "tags", userRS(sTagsField).Value
    End If

    If sPhotoUrlField > "" Then
      dAttributes.Add "remote_photo_url", userRS(sPhotoUrlField).Value
    End If

    If sPhoneField > "" Then
      dAttributes.Add "phone", userRS(sPhoneField).Value
    End If

    If sRoleField > "" Then
      dAttributes.Add "role", userRS(sRoleField).Value
    End If

    If sCustomRoleIDField > "" Then
      dAttributes.Add "custom_role_id", userRS(sCustomRoleIDField).Value
    End If

    If sLocaleField > "" Then
      dAttributes.Add "locale", userRS(sLocaleField).Value
    End If

    If sLocaleIDField > "" Then
      dAttributes.Add "locale_id", userRS(sLocaleIDField).Value
    End If

    ' If you need more custom user fields, add additional entries below as well as above in the settings.
    If sUserFieldKey1 > "" And sUserFieldValue1 > "" Then
      dUserFields.Add Encode_UTF8(sUserFieldKey1), Encode_UTF8(userRS(sUserFieldValue1).Value)
    End If

  If sUserFieldKey2 > "" And sUserFieldValue2 > "" Then
      dUserFields.Add Encode_UTF8(sUserFieldKey2), Encode_UTF8(userRS(sUserFieldValue2).Value)
    End If

    Set GetAuthenticatedUser = dAttributes
  else
    Set GetAuthenticatedUser = Nothing
  end if

  userRS.Close
  oConn.Close
End Function
%>
