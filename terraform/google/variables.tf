variable "docker_password" {
  type        = string
  description = "Docker password."
  default     = "F55BSsu2w^u%t^VPXSfS"
  sensitive   = true
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token."
  default     = "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"
  sensitive   = true
}

variable "google_project_id" {
  type        = string
  description = "Google Cloud project identifier."
  default     = "wager-233003"
}

variable "google_region" {
  type        = string
  description = "Google Cloud region."
  default     = "us-east1"
}

variable "google_zone" {
  type        = string
  description = "Google Cloud zone."
  default     = "us-east1-b"
}
