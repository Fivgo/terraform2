variable "gcp_bucket" {
  type = string
  default = "e1015-bucket"
  description = "The name of the GCP bucket to create"
}


variable "project_id" {
  type = string
  default = "vital-reef-450000-f4"
  description = "The name of the GCP bucket to create"
}

variable "source_file" {
  type = object({
    name        = string
    name_tx     = string
  })
  description = "The YAML file containing client configuration"
  default = {
    name = "SHOULDCHANGE"
    name_tx = "SHOULDCHANGE"
  }
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
