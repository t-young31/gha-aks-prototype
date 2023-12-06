variable "azure_suffix" {
  type        = string
  description = "Suffix used for naming resources"
}

variable "gh_pat" {
  type        = string
  description = "GitHub personal access token with repo:admin"
}

variable "gh_repository" {
  type        = string
  description = "<org>/<repo>"
}
