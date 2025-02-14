# Create controller project
resource "google_project" "controller" {  
    
    name       = var.project_id_con
    project_id = "${var.project_id_con}-1"
    
    billing_account = var.billing_account_id

    lifecycle {
        prevent_destroy = false
    }
}

# Create projects for each client VM
resource "google_project" "client_projects" {
    for_each = local.client
    
    
    name       = "${each.value.name}-project"
    project_id = "${each.value.name}-id"
    
    billing_account = var.billing_account_id

    lifecycle {
        prevent_destroy = false
    }
}
