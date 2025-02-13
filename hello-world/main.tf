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

# Random suffix to ensure unique project IDs
resource "random_id" "project_suffix" {
  byte_length = 4
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





