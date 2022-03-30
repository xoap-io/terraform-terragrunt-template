locals {
  account_name = "services"
  product      = "eks"
  tags         = merge(include.deployment.locals.default_tags, {
  })

}
include "deployment" {
  path   = find_in_parent_folders("deployment.hcl")
  expose = true
}
dependency "organisation" {
  config_path = "../../core/accounts"
}
dependency "shared" {
  config_path = "../../core/shared"
}
dependency "services" {
  config_path = "../../core/services"
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = templatefile(include.deployment.locals.templates.provider, {
    role_arn        = dependency.organisation.outputs.accounts[local.account_name].role_arn
    region          = include.deployment.locals.region
    alias_providers = {
      shared = {
        role_arn = dependency.organisation.outputs.accounts["shared"].role_arn
        region   = include.deployment.locals.region
      }
    }
    tags = local.tags
  })
}

generate "context" {
  path      = "context.auto.tfvars"
  if_exists = "overwrite"
  contents  = templatefile(include.deployment.locals.templates.context, merge(include.deployment.locals.default_context, {
    account_id = dependency.organisation.outputs.accounts[local.account_name].id
    tags       = local.tags
    product    = local.product
  }))
}

inputs = {
  external_dns               = dependency.shared.outputs.dns.default_domain
  kms               = dependency.shared.outputs.kms
  buckets           = dependency.shared.outputs.buckets
  ecr_repositories  = dependency.shared.outputs.ecr_repositories
  eks               = dependency.services.outputs.eks
  infracost_api_key = "bpGXEJicf8d4KUZRda0nwZAbQOYb9bkU"
  database = dependency.shared.outputs.rds
}