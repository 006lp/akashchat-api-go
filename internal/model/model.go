package model

// Model represents the structure of a model's information
type Model struct {
	ID             string   `json:"id"`
	Name           string   `json:"name"`
	Description    string   `json:"description"`
	Temperature    string   `json:"temperature,omitempty"`
	TopP           string   `json:"top_p,omitempty"`
	TokenLimit     int      `json:"token_limit,omitempty"`
	Parameters     string   `json:"parameters,omitempty"`
	Architecture   string   `json:"architecture,omitempty"`
	HFRepo         string   `json:"hf_repo,omitempty"`
	AboutContent   string   `json:"about_content"`
	InfoContent    string   `json:"info_content"`
	ThumbnailID    string   `json:"thumbnail_id"`
	DeployURL      string   `json:"deploy_url,omitempty"`
	Available      bool     `json:"available"`
}