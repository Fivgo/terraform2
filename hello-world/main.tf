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
  credentials = file("./application_default_credentials.json")
  project     = var.project_id
  region      = "us-west1"
  zone        = "us-west1-a"
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

# Create new storage bucket in the US
# location with Standard Storage

resource "google_storage_bucket" "bucket-gen" {
for_each = local.client

 name          = "${var.gcp_bucket}-${each.value.name}"
 location      = "US"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

# Create a new service account for the VM

resource "google_service_account" "vm_srv_acct_gen" {
  for_each = local.client

  account_id   = "vsa-${each.value.name}"
  display_name = "Service Account for my ${each.value.name_tx}"
}

resource "google_storage_bucket_iam_member" "bucket_admin_access" {
  for_each = local.client

  bucket  = google_storage_bucket.bucket-gen[each.value.name].name
  role    = "roles/storage.admin" # need admin role because each vm needs c,w,and d
  member  = "serviceAccount:${google_service_account.vm_srv_acct_gen[each.value.name].email}"
}

# create a hole in the firewall

resource "google_compute_firewall" "default" {
  name    = "default-allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
  source_tags = ["minecraft"]
  target_tags = ["http-server", "https-server"]
}

# Upload a text file as an object
# to the storage bucket

resource "google_storage_bucket_object" "server" {
    for_each = local.client
 name         = "mc-server/server.jar"
 source       = "./materials/mc-server/server.jar"
 content_type = "text/plain"
 bucket       = google_storage_bucket.bucket-gen[each.value.name].id
}

resource "google_storage_bucket_object" "startup" {
  for_each = local.client

 name         = "startup-script.sh"
 source       = "./startup-script.sh"
 content_type = "text/plain"
 bucket       = google_storage_bucket.bucket-gen[each.value.name].id
}

#setup a cluster

resource "google_compute_instance" "vm_inst_gen" {
  for_each = local.client

  name         = "${var.vm_config.base_name}-${each.value.name}"
  machine_type = var.vm_config.machine_type
  zone         = var.vm_config.zone

  tags = var.vm_config.tags

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20250113"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.vm_srv_acct_gen[each.value.name].email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  #metadata_startup_script = "${file("startup-script.sh")}"

  metadata = {
    startup-script-url = "gs://${var.gcp_bucket}-${each.value.name}/startup-script.sh"
  }


  ## Install necessary packages
  #sudo apt-get update
  #sudo apt-get install -y jq

  #metadata_startup_script = "echo hi there > /test.txt"      #"${file("startup-script.sh")}"
}
