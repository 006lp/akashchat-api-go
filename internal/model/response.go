package model

// APIResponse represents the standard API response format
type APIResponse struct {
	Code int         `json:"code"`
	Data interface{} `json:"data"`
}

// ImageGenerationData represents response data for image generation
type ImageGenerationData struct {
	Model  string `json:"model"`
	JobID  string `json:"jobId"`
	Prompt string `json:"prompt"`
	Pic    string `json:"pic"`
}

// ErrorData represents error response data
type ErrorData struct {
	Message string `json:"msg"`
}

// SessionResponse represents the session response from Akash
type SessionResponse struct {
	SessionToken string `json:"session_token,omitempty"`
}

// OpenAIChatCompletion represents the chat completion response in OpenAI format.
type OpenAIChatCompletion struct {
	ID      string   `json:"id"`
	Object  string   `json:"object"`
	Created int64    `json:"created"`
	Model   string   `json:"model"`
	Choices []Choice `json:"choices"`
	Usage   Usage    `json:"usage"`
}

// Choice represents a single choice in the chat completion response.
type Choice struct {
	Index        int     `json:"index"`
	Message      Message `json:"message"`
	FinishReason string  `json:"finish_reason"`
}

// Message represents a message in the chat completion response.
type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

// Usage represents the token usage statistics.
type Usage struct {
	CompletionTokens int `json:"completion_tokens"`
	PromptTokens     int `json:"prompt_tokens"`
	TotalTokens      int `json:"total_tokens"`
}

// OpenAIStreamCompletion represents the chat completion response in OpenAI stream format.
type OpenAIStreamCompletion struct {
	ID      string               `json:"id"`
	Object  string               `json:"object"`
	Created int64                `json:"created"`
	Model   string               `json:"model"`
	Choices []OpenAIStreamChoice `json:"choices"`
	Usage   *Usage               `json:"usage,omitempty"`
}

// OpenAIStreamChoice represents a single choice in the chat completion stream response.
type OpenAIStreamChoice struct {
	Index        int    `json:"index"`
	Delta        Delta  `json:"delta"`
	FinishReason *string `json:"finish_reason"`
}

// Delta represents a delta in the chat completion stream response.
type Delta struct {
	Role    string `json:"role,omitempty"`
	Content string `json:"content,omitempty"`
}

// OpenAIModel represents a single model in the OpenAI models list.
type OpenAIModel struct {
	ID         string      `json:"id"`
	Object     string      `json:"object"`
	Created    int64       `json:"created"`
	OwnedBy    string      `json:"owned_by"`
	Permission interface{} `json:"permission"`
	Root       string      `json:"root"`
	Parent     interface{} `json:"parent"`
}

// OpenAIModelsList represents the list of OpenAI models.
type OpenAIModelsList struct {
	Object string        `json:"object"`
	Data   []OpenAIModel `json:"data"`
}
