package sso

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"time"

	jwt "github.com/dgrijalva/jwt-go"
)

func (ssc SSOController) GenerateZendeskRedirectURLHandler(w http.ResponseWriter, r *http.Request) {

	// Expected client input
	type ReqBody struct {
		Name     string `json:"name"`
		Email    string `json:"email"`
		ReturnTo string `json:"return_to"`
	}
	req_body := &ReqBody{}

	// Decode client input to req_body
	if err := json.NewDecoder(r.Body).Decode(&req_body); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Expected zendesk payload
	type ZendeskPayload struct {
		Name  string `json:"name"`
		Email string `json:"email"`

		// Contains `iat`, `jti` fields
		jwt.StandardClaims
	}

	// Construct payload for signing
	payload := &ZendeskPayload{
		req_body.Name,
		req_body.Email,
		jwt.StandardClaims{
			IssuedAt: time.Now().Unix(),
			Id:       irv_core.Gen_irv_id(),
		},
	}

	// Create token from payload
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, payload)

	// Sign jwt with zendesk secret
	signed_jwt, err := token.SignedString([]byte(os.Getenv("ZENDESK_KEY")))
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// Construct redirect URL
	redirect_base := fmt.Sprintf("https://%s.zendesk.com/access/jwt", os.Getenv("ZENDESK_SUBDOMAIN"))

	// Use net/url to set params and encode URL
	var Url *url.URL
	Url, _ = url.Parse(redirect_base)
	parameters := url.Values{}
	parameters.Add("jwt", signed_jwt)
	if req_body.ReturnTo != "" {
		parameters.Add("return_to", req_body.ReturnTo)
	}
	Url.RawQuery = parameters.Encode()
	redirect_url := Url.String()

	// Respond to client
	res_body, err := json.Marshal(map[string]string{
		"redirect": redirect_url,
	})
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(res_body)

}
