# Order: main, vars & secrets, projects, apis, buckets, permissions, vms, network

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
  all_clients = module.client_configs.configs
  
  # Create VM names for each client based on their config
  client = { for cli in local.all_clients : cli.name => {
     name    = cli.name
     name_tx = cli.name_tx
   }}

}
