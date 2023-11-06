// Using JWT from PHP requires you to first either install the JWT PEAR package from
// http://pear.php.net/pepr/pepr-proposal-show.php?id=688 or get the JWT project
// from https://github.com/firebase/php-jwt on GitHub.

<?php
include_once "Authentication/JWT.php";

function generate_jwt($name, $email) {
  $key       = getenv('ZENDESK_SHARED_KEY');
  $now       = time();

  $token = array(
    "jti"   => md5($now . rand()),
    "iat"   => $now,
    "name"  => $name,
    "email" => $email
  );

  $jwt = JWT::encode($token, $key, 'HS256');
  return $jwt;
}

?>
