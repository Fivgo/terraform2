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
  project     = var.project_id
  region      = "us-west1"
  zone        = "us-west1-a"
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}


# Create a new service account for the VM

resource "google_service_account" "default" {
  account_id   = "my-vm-service-account"
  display_name = "Service Account for my VM"
}

resource "google_project_iam_member" "default" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.default.email}"
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

resource "google_storage_bucket_object" "startup" {
 name         = "startup-script.sh"
 source       = "./startup-script.sh"
 content_type = "text/plain"
 bucket       = google_storage_bucket.static.id
}

#setup a cluster

resource "google_compute_instance" "default" {
  name         = "my-vm"
  machine_type = "n1-standard-1"
  zone         = "us-west1-a"

  tags = ["http-server", "https-server"]

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
    email  = google_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  #metadata_startup_script = "${file("startup-script.sh")}"

  metadata = {
    startup-script-url = "gs://${var.gcp_bucket}/startup-script.sh"
  }


  ## Install necessary packages
  #sudo apt-get update
  #sudo apt-get install -y jq

  #metadata_startup_script = "echo hi there > /test.txt"      #"${file("startup-script.sh")}"
}
