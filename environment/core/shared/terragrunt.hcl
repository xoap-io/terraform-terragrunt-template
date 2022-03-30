locals {
  environment = "core"
  product = ""
  tags        = merge(include.deployment.locals.default_tags, {
    environment = local.environment
  })

}
include "deployment" {
  path   = find_in_parent_folders("deployment.hcl")
  expose = true
}
dependency "organisation" {
  config_path = "../accounts"
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = templatefile(include.deployment.locals.templates.provider, {
    role_arn        = dependency.organisation.outputs.accounts["shared"].role_arn
    region          = include.deployment.locals.region
    alias_providers = {
      services = {
        role_arn = dependency.organisation.outputs.accounts["services"].role_arn
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
    account_id  = dependency.organisation.outputs.accounts["shared"].id
    tags        = local.tags
    environment = local.environment
    product = local.product
  }))
}

inputs = {
  buckets         = {
    deployment = {
      website_enabled = false
      cors_enabled    = false
    }
  }
  kms_keys        = {
    storage = ["storage"]
    default = ["default", "fallback"]
    workspaces = ["workspaces"]
  }
  vpc_cidr        = "10.10.0.0/16"
  subnet_mappings = {
    private  = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
    public   = ["10.10.20.0/24", "10.10.21.0/24", "10.10.22.0/24"]
    database = ["10.10.30.0/24", "10.10.31.0/24", "10.10.32.0/24"]
  }

  ecr_repositories = [
    "keycloak",
    "kong",
    "whoami",
    "svc-teams",
    "svc-user"
  ]
  default_domain = "brauneck.solutions"
  dns =     {
    "brauneck.org" = {
      mx = ""
      ms_dns_enabled = true
    }
    "richter-brauneck.com" = {
      mx = "richterbrauneck-com01i"
      ms_dns_enabled = true
    }
    "brauneck.solutions" = {
      mx = ""
      ms_dns_enabled = false
    }
  }
  organisation = dependency.organisation.outputs.organisation
}