terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Configuración para HashiCorp Cloud (Terraform Cloud)
  cloud {
    organization = "cama2603cama-tech-org"

    workspaces {
      name = "gcp-terraform-cloud-nat"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region_us_west
}