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

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jwt.JWTClaimsSet;

import java.util.Date;
import java.util.UUID;

public class JWT {
  private static final String SHARED_KEY = System.getenv("SHARED_KEY");

  public String generate(String name, String email) throws JOSEException {
    // Given a name and email
    // Compose the JWT claims set
    JWTClaimsSet jwtClaims = new JWTClaimsSet.Builder()
      .issueTime(new Date())
      .jwtID(UUID.randomUUID().toString())
      .claim("name", name)
      .claim("email", email)
      .build();

    // Create JWS header with HS256 algorithm
    JWSHeader header = new JWSHeader.JWSHeaderBuilder(JWSAlgorithm.HS256).build();
    
    // Create JWT payload
    Payload payload = new Payload(jwtClaims.toJSONObject());;

    // Create JWS object
    JWSObject jwsObject = new JWSObject(header, payload);

    // Create HMAC signer
    JWSSigner signer = new MACSigner(SHARED_KEY.getBytes());

    jwsObject.sign(signer);
    
    // Serialize to JWT compact form
    return jwsObject.serialize();
  }
}
