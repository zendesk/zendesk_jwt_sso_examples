# Zendesk SSO JWT examples

The files in this repository are examples and not guaranteed to run or be correct. They should explain you how you can make Zendesk SSO work with JWT from your stack. Pull requests much appreciated.

The `jwt_generation` folder contains examples on how to generate JWTs. You can generate JWTs on your server and return it to your client. You may also want to return the Zendesk JWT URL with your subdomain to prevent hardcoding it in your client code.

The `form_submission` folder contains examples of how to trigger the POST request with the JWT in the body of the request. This must be done via form submission as other methods of creating POST requests such as axios or fetch will be blocked by CORS.

## Documentation

Further documentation on JWT based Zendesk SSO is available [in our knowledge base](https://support.zendesk.com/hc/en-us/articles/4408845838874-Enabling-JWT-single-sign-on)

## Contributing

Examples and improvements much appreciated.

### License

Copyright 2013-2023 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
