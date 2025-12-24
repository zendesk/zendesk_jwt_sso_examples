// Description: This file contains the TypeScript code for opening a Zendesk ticket with JWT authentication.
// This code is written in TypeScript.
function openZendesk (): void {
    // Create a form element
    const form: HTMLFormElement = document.createElement('form')
    form.setAttribute('id', 'zendesk-login')
    form.setAttribute('action', 'https://example.zendesk.com/access/jwt')
    form.setAttribute('method', 'POST')
    form.setAttribute('target', '_blank')

    // Replace the following line with the actual JWT token
    const jwtToken: string = ''

    // Create a hidden input element for the JWT token
    const jwt: HTMLInputElement = document.createElement('input')
    jwt.setAttribute('type', 'hidden')
    jwt.setAttribute('name', 'jwt')
    jwt.setAttribute('value', jwtToken)

    form.appendChild(jwt)
    document.body.appendChild(form)
    form.submit()

    // Remove the form after submission
    document.getElementById('zendesk-login')?.remove()
}
