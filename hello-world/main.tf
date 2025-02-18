# Order: main, modules, vars & secrets, projects, apis, buckets, permissions, vms, network

terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "Fivgo-Test-1"
    workspaces {
      tags = ["networking"]
    }
  }
}

provider "google" {
  #alias = "admin"
  credentials = file("./application_default_credentials.json")
  project     = "vital-reef-450000-f4" #var.project_id_main
  region      = "us-west1"
  #zone        = "us-west1-a"
}

# # Import all current clients
module "client_configs" {
  source = "./modules/clients"
}

locals {
  # Access all client configurations
  client = module.client_configs.configs
}
