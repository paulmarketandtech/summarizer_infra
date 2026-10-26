variable "pve_endpoint" {
  type        = string
  description = "e.g. https://pve.lan:8006/"
}

variable "pve_api_token" {
  type      = string
  sensitive = true
}

variable "pve_node" {
  type    = string
  default = "pve"
}
