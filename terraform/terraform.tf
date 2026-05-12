terraform {
  required_version = "~> 1.15.0"

  backend "s3" {}

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.13.0"
    }
    jq = {
      source  = "massdriver-cloud/jq"
      version = "0.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.8"
    }
  }
}

provider "oci" {
  config_file_profile = "DEFAULT"
}
