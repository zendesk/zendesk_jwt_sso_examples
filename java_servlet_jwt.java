/*
  This example depends on the following jar files

  commons-codec.jar from http://commons.apache.org/proper/commons-codec/
  json-smart.jar from https://code.google.com/p/json-smart/
  nimbus-jose-jwt.jar from https://bitbucket.org/nimbusds/nimbus-jose-jwt/overview
  
  Because of this [1] issue in nimbus-jose-jwt, please make sure to use a 
  version >= 2.13.1 as Zendesk expects seconds in the iat parameter
  [1]: https://bitbucket.org/nimbusds/nimbus-jose-jwt/issue/35/jwtclaimsset-milliseconds-vs-seconds-issue
*/

package com.zendesk.login;

import java.util.Date;
import java.util.UUID;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.*;
import com.nimbusds.jose.util.*;
import com.nimbusds.jwt.*;

public class JWT extends HttpServlet {
  private static final String SHARED_KEY = "{my zendesk token}";
  private static final String SUBDOMAIN  = "{my zendesk subdomain}";

  @Override
  protected void service(HttpServletRequest request, HttpServletResponse response)
    throws IOException, ServletException {

    // Given a user instance
    // Compose the JWT claims set
    JWTClaimsSet jwtClaims = new JWTClaimsSet();
    jwtClaims.setIssueTime(new Date());
    jwtClaims.setJWTID(UUID.randomUUID().toString());
    // jwtClaims.setCustomClaim("name", user.name);
    // jwtClaims.setCustomClaim("email", user.email);

    // Create JWS header with HS256 algorithm
    JWSHeader header = new JWSHeader(JWSAlgorithm.HS256);
    header.setContentType("text/plain");

    // Create JWS object
    JWSObject jwsObject = new JWSObject(header, new Payload(jwtClaims.toJSONObject()));

    // Create HMAC signer
    JWSSigner signer = new MACSigner(SHARED_KEY.getBytes());

    try {
      jwsObject.sign(signer);
    } catch(com.nimbusds.jose.JOSEException e) {
      System.err.println("Error signing JWT: " + e.getMessage());
      return;
    }

    // Serialise to JWT compact form
    String jwtString = jwsObject.serialize();

    String redirectUrl = "https://" + SUBDOMAIN + ".zendesk.com/access/jwt?jwt=" + jwtString;

    String returnTo = request.getParameter("return_to");
    if (returnTo != null) {
        redirectUrl += "&return_to=" + returnTo;
    }

    response.sendRedirect(redirectUrl);
  }
}
