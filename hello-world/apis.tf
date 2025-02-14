#--------CONTROLLER BUCKETS--------
# Enable required APIs in controller project
resource "google_project_service" "controller_apis" {
    
    project  = "${var.project_id_con}-1"#"vital-reef-450000-f4" #google_project.controller.project_id
    
    for_each = toset([
        "compute.googleapis.com",
        "iam.googleapis.com",
        "cloudresourcemanager.googleapis.com"
    ])
    
    service = each.key
}


#--------CLIENT BUCKETS--------

#Create apis for each client project
locals {
  project_services = merge([
    for project_id, project in google_project.client_projects : {
      for service in ["compute.googleapis.com", "storage.googleapis.com", "iam.googleapis.com"] :
      "${project_id}-${service}" => {
        project_id = project.project_id
        service    = service
      }
    }
  ]...)
}

resource "google_project_service" "client_apis" {
  
  for_each = local.project_services
  
  project = each.value.project_id
  service = each.value.service
  
  disable_dependent_services = true
  disable_on_destroy        = false
}
