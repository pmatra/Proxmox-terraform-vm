terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.10"
    }
  }
}

  provider "proxmox" {
# url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = "https://10.1.10.193:8006/api2/json"
# api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "terraform@pam!token"
# this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "cloudinit-test" {
  count       = 1
  name        = "test-vm-${count.index + 1}"
  desc        = "testing terraform proxmox plugin"
  target_node = "pve"
  clone       = "ubuntu21-cloudinit-template"
  cores       = 2
  sockets     = 1
  memory      = 2048

  ipconfig0 = "ip=10.1.10.9${count.index + 1}/24,gw=10.1.10.1"


  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    type         = "scsi"
    storage      = "local-lvm"
    size         = "10G"
  }
   lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
