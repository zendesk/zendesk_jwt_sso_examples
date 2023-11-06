package sso

import (
	"os"
	"time"

	jwt "github.com/dgrijalva/jwt-go"
	"github.com/google/uuid"
)

var shared_key = os.Getenv("ZENDESK_KEY")

// Expected Zendesk payload
type ZendeskPayload struct {
	Name  string `json:"name"`
	Email string `json:"email"`

	// Contains `iat`, `jti` fields
	jwt.StandardClaims
}

func GenerateJwt(name, email string) string {
	// Construct payload for signing
	payload := &ZendeskPayload{
		Name:  name,
		Email: email,
		StandardClaims: jwt.StandardClaims{
			IssuedAt: time.Now().Unix(),
			Id:       uuid.New().String(),
		},
	}

	// Create token from payload
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, payload)
	// Sign JWT with Zendesk secret
	signed_jwt, err := token.SignedString([]byte(shared_key))

	// handle error if err != nil

	return signed_jwt
}
