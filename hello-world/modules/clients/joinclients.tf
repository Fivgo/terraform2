
variable "default_machine_type" {
  type = string
  default = "n1-standard-1"
  description = "The name of the type of vm to create"
}

variable "default_zone_type" {
  type = string
  default = "us-west1-a"
  description = "The name of the zone to create in"
}

variable "default_disk_type" {
  type = object({
    disk_size : string
    disk_type : string
  })
  default = {
    disk_size : "10",
    disk_type : "pd-balanced"
  }
  description = "default disk variables enitialized"
}

variable "default_startup_script" {
  type = string
  default = "startup-script.sh"
  description = "The name of the startup script"
}

variable "default_file_path" {
  type = string
  default = "mc-server/server.jar"
  description = "The name of the file path"
}



locals {
  # Read all YAML files from the configs directory
  client_files = fileset("${path.module}/configs", "*.yaml")
  
  client_configs = [
    for file in local.client_files : 
    yamldecode(file("${path.module}/configs/${file}")).client
  ]

}

output "configs" {
  #value = local.client_configs


  description = "Map of client instances with their configurations"
  value = {
    for client in local.client_configs : client.name => {
      name         = client.name
      name_tx      = client.name_tx
      machine_type = can(client.machine_type) ? client.machine_type : var.default_machine_type
      startup_script = can(client.startup_script) ? client.startup_script : var.default_startup_script
      zone = can(client.zone) ? client.zone : var.default_zone_type
      disk = can(client.disk) ? client.disk : var.default_disk_type
      file_path = can(client.file_path) ? client.file_path : var.default_file_path
    }
  }

}