terraform {
  required_version = ">= 1.15.2"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.21"
    }
  }
}
