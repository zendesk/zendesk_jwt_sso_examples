// make the request to your login service
function handleLogin() {
  const xhr = jQuery.post("/internal/login", $("#yourLoginForm").serialize());

  xhr.success(function(data) {
    // On successful login - add JWT to a hidden form and submit
    // Return the JWT generated from your sever and the Zendesk 
    // JWT URL, usually in the format of 
    // https://{your_subdomain}.zendesk.com/access/jwt 
    var form = $('<form />').attr("method", "POST").
      attr("action", data['url'] + window.location.search);

    $('<input />').attr("type", "hidden").
      attr("name", "jwt").
      attr("value", data['jwt']).
      appendTo(form);

    form.appendTo('body');
    form.submit();
  }).fail(function() {
    // Handle login failures
    alert("Authentication failed");
  });
}