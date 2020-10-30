# TERRAFORM
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-3"
}

module "img_registry" {
  source        = "git::git@github.com:gilacost/terraform-modules.git//image-registries/ecr?ref=v0.0.1"
  img_repo_name = "ecs-docs"
}

module "ecs_cluster" {
  source             = "git::git@github.com:gilacost/terraform-modules.git//services/aws/ecs-cluster?ref=v0.0.1"
  image_registry_url = module.img_registry.url
  show_ip            = false
  cluster_name       = "sense-eight"
}

output "reapo_url" {
  value = module.img_registry.url
}

output "access" {
  value = module.ecs_cluster.access
}
