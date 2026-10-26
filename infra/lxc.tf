resource "proxmox_download_file" "alpine_lxc" {
  node_name    = var.pve_node
  datastore_id = "local"
  content_type = "vztmpl"
  url          = "http://download.proxmox.com/images/system/alpine-3.23-default_20260116_amd64.tar.xz"
}

resource "proxmox_virtual_environment_container" "alpine_test" {
  node_name = var.pve_node
  vm_id     = 7020
  tags      = ["terraform", "alpine"]

  unprivileged  = true
  start_on_boot = true

  operating_system {
    template_file_id = proxmox_download_file.alpine_lxc.id
    type             = "alpine"
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 128
    swap      = 256
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  initialization {
    hostname = "alpine-test"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }
  }

  startup {
    order = 10
  }
}
