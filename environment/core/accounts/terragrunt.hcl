locals {
  tags        = include.deployment.locals.default_tags
}
include "deployment" {
  path   = find_in_parent_folders("deployment.hcl")
  expose = true
}
dependency "organisation" {
  config_path = "../accounts"
}
dependency "shared" {
  config_path = "../shared"
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = templatefile(include.deployment.locals.templates.provider, {
    role_arn        = dependency.organisation.outputs.accounts[local.account_name].role_arn
    region          = include.deployment.locals.region
    alias_providers = {
    }
    tags            = local.tags
  })
}

generate "context" {
  path      = "context.auto.tfvars"
  if_exists = "overwrite"
  contents  = templatefile(include.deployment.locals.templates.context, merge(include.deployment.locals.default_context, {
    account_id  = dependency.organisation.outputs.accounts[local.account_name].id
  }))
}

inputs = {
}