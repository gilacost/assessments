terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.12.4"
    }
  }
}

variable "linode_token" {}

module "linode" {
  source       = "../../mono/infrastructure/terraform/modules/linode/"
  linode_token = var.linode_token
  environment  = "test"
  group        = "teller"
  tags         = ["docs", "apache", "docker"]
  deploy_stack = false
  linode_image = "private/9393980"
  linode_type  = "g6-nanode-1"
  disk_size    = 25088
  swap_size    = 512
}

output "all_from_linode" {
  value = module.linode
}
