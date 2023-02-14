terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      # version = "..."
    }
    oci = {
      source = "oracle/oci"
      version = "4.101.0"
    }
  }
}