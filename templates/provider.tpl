variable "context" {
  type        = object({
    organization = string
    environment  = string
    account      = string
    product      = string
    tags         = map(string)
  })
  description = "Default environmental context"
}

provider "aws" {
  region = "${region}"
  skip_requesting_account_id  = true # this can be tricky
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
%{if role_arn != ""}
  assume_role {
    role_arn = "${role_arn}"
  }
%{ endif }
  default_tags {
    tags = {
    %{ for key,value in tags ~}
    ${key} =  "${value}"
    %{ endfor ~}
    }
  }
}

%{ for pkey,pvalue in alias_providers ~}
provider "aws" {
  alias  = "${pkey}"
  region = "${pvalue.region}"
  skip_requesting_account_id  = true # this can be tricky
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  assume_role {
    role_arn = "${pvalue.role_arn}"
  }
  default_tags {
    tags = {
    %{ for key,value in tags ~}
    ${key} =  "${value}"
    %{ endfor ~}
    }
  }
}
%{ endfor ~}

terraform {
  backend "s3" {
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }

  required_providers  {
    aws = {
        source  = "hashicorp/aws"
        version = ">= 4.3.0"
     }
     helm = {
        source  = "hashicorp/helm"
        version = ">= 2.4.1"
     }
     http = {
        source  = "hashicorp/http"
        version = ">= 2.1.0"
     }
     kubernetes = {
        source  = "hashicorp/kubernetes"
        version = ">= 2.8.0"
     }
     kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.0"
     }
    local = {
        source  = "hashicorp/local"
        version = ">= 2.1.0"
     }
     random = {
        source  = "hashicorp/random"
        version = ">= 3.1.0"
     }
     template = {
        source  = "hashicorp/template"
        version = ">= 2.2.0"
     }
     time = {
        source  = "hashicorp/time"
        version = ">= 0.7.2"
     }
     tls = {
        source  = "hashicorp/tls"
        version = ">= 3.1.0"
     }
     vault = {
        source  = "hashicorp/vault"
        version = ">= 3.3.1"
     }
     keycloak = {
        source  = "mrparkers/keycloak"
        version = ">= 3.7.0"
     }
     postgresql = {
        source  = "cyrilgdn/postgresql"
        version = ">= 1.15.0"
     }
    mysql = {
      source = "winebarrel/mysql"
      version = "1.10.6"
    }
  }
}
