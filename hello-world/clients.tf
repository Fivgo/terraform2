# # Import all current clients
module "client_configs" {
  source = "./modules/clients"
}

locals {
  # Access all client configurations
  all_clients = module.client_configs.configs
  
  # Create VM names for each client based on their config
  client = { for cli in local.all_clients : cli.name => {
     name    = cli.name
     name_tx = cli.name_tx
   }}

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

# Create projects for each client VM
resource "google_project" "client_projects" {
    for_each = local.client
    #provider = google.admin
    
    name       = "${each.value.name}-project"
    project_id = "${each.value.name}-id"
    
    billing_account = var.billing_account_id

    lifecycle {
        prevent_destroy = false
    }
}

#Create apis for each client project
resource "google_project_service" "client_apis" {
  #provider = google.admin
  for_each = local.project_services
  
  project = each.value.project_id
  service = each.value.service
  
  disable_dependent_services = true
  disable_on_destroy        = false
}

# Create new storage bucket in the US
# location with Standard Storage

resource "google_storage_bucket" "bucket-gen" {
    #provider = google.admin
    for_each = local.client

    name          = "${var.gcp_bucket}-${each.value.name}"
    location      = "US"
    storage_class = "STANDARD"
    project       = google_project.client_projects[each.value.name].project_id

    uniform_bucket_level_access = true
}

# Create a new service account for the VM
resource "google_service_account" "vm_srv_acct_gen" {
    #provider = google.admin
    for_each = local.client
    project = google_project.client_projects[each.value.name].project_id
    account_id   = "vsa${each.value.name}"
    display_name = "Service Account for my ${each.value.name_tx}"
}

resource "google_storage_bucket_iam_member" "bucket_admin_access" {
    #provider = google.admin
    for_each = local.client

    bucket  = google_storage_bucket.bucket-gen[each.value.name].name
    role    = "roles/storage.admin" # need admin role because each vm needs c,w,and d
    member  = "serviceAccount:${google_service_account.vm_srv_acct_gen[each.value.name].email}"
}

# Grant the user the ability to use service accounts
resource "google_service_account_iam_binding" "vm_sa_user" {
  #provider = google.admin
  for_each = local.client

  service_account_id = "projects/${google_project.client_projects[each.value.name].project_id}/serviceAccounts/${google_service_account.vm_srv_acct_gen[each.value.name].email}"
  role               = "roles/iam.serviceAccountUser"
  
  members = [
    "user:TheFiveEgos@gmail.com"  # Replace with your email
  ]
}

# Additionally, you might want to grant project-level service account user role
# resource "google_project_iam_binding" "project_sa_user" {
#   #provider = google.admin
#   for_each = google_service_account.vm_srv_acct_gen
  
#   project = each.value.account_id
#   role    = "roles/iam.serviceAccountUser"
  
#   members = [
#     "user:TheFiveEgos@gmail.com"  # Replace with your email
#   ]
# }

#setup a cluster

resource "google_compute_instance" "vm_inst_gen" {
  for_each = local.client
  #provider = google.admin
  name         = "${var.vm_config.base_name}-${each.value.name}"
  machine_type = var.vm_config.machine_type
  zone         = var.vm_config.zone
  project      = google_project.client_projects[each.value.name].project_id

  tags = var.vm_config.tags

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
    email  = google_service_account.vm_srv_acct_gen[each.value.name].email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    startup-script-url = "gs://${var.gcp_bucket}-${each.value.name}/startup-script.sh"
  }

}
