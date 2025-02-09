terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "Fivgo-Test-1"
    workspaces {
      tags = ["networking"]
    }
  }
}

variable "gcp_bucket" {
  type = string
  default = "e-bucket-terraform-built"
  description = "The name of the GCP bucket to create"
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
  region      = "us-central1"
  zone        = "us-central1-c"
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

resource "google_storage_bucket_object" "default" {
 name         = "sample_file.txt"
 source       = "./sample_file.txt"
 content_type = "text/plain"
 bucket       = google_storage_bucket.static.id
}