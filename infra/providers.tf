provider "proxmox" {
  endpoint  = var.pve_endpoint
  api_token = var.pve_api_token
  insecure  = true # self-signed cert; fix this later

  ssh {
    agent    = true
    username = "root"
  }
}
