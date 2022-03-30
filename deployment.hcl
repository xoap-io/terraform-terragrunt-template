download_dir = "${local.deployment_deployments_dir}/cache"
locals {
  deployment_deployments_dir = get_parent_terragrunt_dir()
  relative_deployment_path   = path_relative_to_include()
  stack_dir                  = "${local.deployment_deployments_dir}/terraform//"
  template_files_dir         = "${local.deployment_deployments_dir}/templates"
  templates                  = {
    provider = "${local.template_files_dir}/provider.tpl"
    context  = "${local.template_files_dir}/context.tpl"
  }
  deployment_path_components = compact(split("/", local.relative_deployment_path))
  stack                      = reverse(local.deployment_path_components)[0]
  tier                       = local.deployment_path_components[1]
  storage_bucket             = get_env("STORAGE_BUCKET", "storage-terraform-176100216432")
  storage_key                = "${local.stack}.tfstate"
  region                     = get_env("AWS_REGION", "eu-central-1")
  default_context            = {
    organisation = "Brauneck Solutions"
    environment = local.tier
  }

  default_tags     = {
    stack      = local.stack
    automation = "terraform"
    automation_tool = "terragrunt"
    organisation = ""
    environment = local.tier
  }
}
terraform {
  source = "${local.stack_dir}/${local.stack}/"
}

remote_state {
  backend = "s3"
  config  = {
    bucket = local.storage_bucket
    key    = local.storage_key
    region = local.region
  }
}