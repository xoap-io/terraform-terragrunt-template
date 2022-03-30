locals {
  account_name = "services"
  product      = "api"
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
dependency "eks" {
  config_path = "../eks"
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
    tags            = local.tags
  })
}

generate "context" {
  path      = "context.auto.tfvars"
  if_exists = "overwrite"
  contents  = templatefile(include.deployment.locals.templates.context, merge(include.deployment.locals.default_context, {
    account_id  = dependency.organisation.outputs.accounts[local.account_name].id
    tags        = local.tags
    product     = local.product
  }))
}

inputs = {
  vpc              = dependency.shared.outputs.vpc
  dns              = dependency.shared.outputs.dns
  kms              = dependency.shared.outputs.kms
  buckets          = merge(dependency.shared.outputs.buckets, dependency.services.outputs.buckets)
  rds              = dependency.shared.outputs.rds
  ecr_repositories = dependency.shared.outputs.ecr_repositories
  keycloak         = dependency.eks.outputs.keycloak
}