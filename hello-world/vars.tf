variable "gcp_bucket" {
  type = string
  default = "e1015-bucket"
  description = "The name of the GCP bucket to create"
}


variable "project_id_main" {
  type = string
  default = "vital-reef-450000-f4"
  description = "The name of the GCP project for main"
}

variable "project_id_cli" {
  type = string
  default = "vm-cli"
  description = "The name of the GCP project for cli"
}

variable "project_id_con" {
  type = string
  default = "vm-controller"
  description = "The name of the GCP project for con"
}


# Define common VM properties
variable "vm_config" {
  type = object({
    machine_type = string
    zone         = string
    disk_size    = number
    base_name    = string
    tags         = list(string)
  })
  default = {
    machine_type = "n1-standard-1"
    zone         = "us-west1-a"
    disk_size    = 10
    base_name    = "app-vm"
    tags = ["http-server", "https-server"]
  }
}

variable "controller_zone" {
  type = string
  default = "us-west1-a"
  description = "The zone in which to create the controller VM"
  
}
