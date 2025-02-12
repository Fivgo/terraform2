locals {
  # Read all YAML files from the configs directory
  client_files = fileset("${path.module}/configs", "*.yaml")
  
  # Parse each YAML file and create a map of client configs
  client_configs = {
    for filename in local.client_files :
    trimsuffix(filename, ".yaml") => yamldecode(file("${path.module}/configs/${filename}"))
  }
}

output "configs" {
  value = local.client_configs
}