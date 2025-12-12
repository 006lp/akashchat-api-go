package handler

import (
	"net/http"

	"github.com/006lp/akashchat-api-go/internal/model"
	"github.com/gin-gonic/gin"
)

// AuthMiddleware is a middleware function that checks for a valid bearer token in the Authorization header
// If the token is valid, the request is allowed to proceed.
// If the token is missing or invalid, a 401 Unauthorized response is returned.
func AuthMiddleware(bearerToken string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, model.APIResponse{
				Code: 401,
				Data: model.ErrorData{Message: "Authorization header is required"},
			})
			c.Abort()
			return
		}

		if authHeader != "Bearer "+bearerToken {
			c.JSON(http.StatusUnauthorized, model.APIResponse{
				Code: 401,
				Data: model.ErrorData{Message: "Invalid token"},
			})
			c.Abort()
			return
		}
		c.Next()
	}
}
