import { useRef } from 'react'

const YOUR_ZENDESK_SUBDOMAIN = 'subdomain'

function App() {
  const formRef = useRef(null);
  const inputRef = useRef(null);

  const handleClick = async () => {
    const response = await handleYourLogin()
    // on successful user authentication, pass the JWT in the response
    // extract the JWT from the response data
    const jwt = response.data.jwt

    // add the JWT to a hidden form on your login page
    inputRef.current.value = jwt

    formRef.current.submit()
  }

  return (
    <div>
      <YourLoginForm>
        ...
        <button
          onClick={handleClick}
        >
          Log in
        </button>
      </YourLoginForm>
      <form ref={formRef} action={`https://${YOUR_ZENDESK_SUBDOMAIN}.zendesk.com/access/jwt`} method="post">
        <input ref={inputRef} type="hidden" name="jwt"></input>
      </form>
    </div>
  );
}

export default App;
