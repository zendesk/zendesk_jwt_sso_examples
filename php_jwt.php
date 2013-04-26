// Using JWT from PHP requires you to first either install the JWT PEAR package from
// http://pear.php.net/pepr/pepr-proposal-show.php?id=688 or get the JWT project
// from https://github.com/firebase/php-jwt on GitHub.

<?php
include_once "Authentication/JWT.php";

// Log your user in.

$key       = "{my zendesk shared key}";
$subdomain = "{my zendesk subdomain}";

$token = array(
  "jti"   => md5($now . rand()),
  "iat"   => time(),
  "name"  => $user->name,
  "email" => $user->email
);

$jwt = JWT::encode($token, $key);

// Redirect
header("Location: https://" . $subdomain . ".zendesk.com/access/jwt?jwt=" . $jwt);
?>
