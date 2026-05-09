terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.12.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.8"
    }
  }
}
