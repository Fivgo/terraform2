terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "Fivgo-Test-1"
    workspaces {
      tags = ["networking"]
    }
  }
}


# variable "gcp_credentials" {
#   type = string
#   sensitive = true
#   description = "Google Cloud service account credentials"
# }


provider "google" {
  #credentials = "${file("account.json")}"
  credentials = file("./application_default_credentials.json")
  project     = "vital-reef-450000-f4"
  region      = "us-west1"
  zone        = "us-west1-a"
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}

# Create new storage bucket in the US
# location with Standard Storage

resource "google_storage_bucket" "static" {
 name          = var.gcp_bucket
 location      = "US"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

# Upload a text file as an object
# to the storage bucket

resource "google_storage_bucket_object" "sample" {
 name         = "sample_file.txt"
 source       = "./sample_file.txt"
 content_type = "text/plain"
 bucket       = google_storage_bucket.static.id
}

resource "google_storage_bucket_object" "server" {
 name         = "mc-server/server.jar"
 source       = "./materials/mc-server/server.jar"
 content_type = "text/plain"
 bucket       = google_storage_bucket.static.id
}


#setup a cluster

resource "google_compute_instance" "default" {
  name         = "my-vm"
  machine_type = "n1-standard-1"
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-arm64-v20250113"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
  metadata_startup_script = file("./startup-script.sh")
}
