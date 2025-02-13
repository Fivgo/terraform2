# Create controller project
resource "google_project" "controller" {  
    #provider = google.admin
    name       = var.project_id_con
    project_id = "${var.project_id_con}-1"
    
    billing_account = var.billing_account_id

    lifecycle {
        prevent_destroy = false
    }
}

# Enable required APIs in controller project
resource "google_project_service" "controller_apis" {
    #provider = google.admin
    project  = "${var.project_id_con}-1"#"vital-reef-450000-f4" #google_project.controller.project_id
    
    for_each = toset([
        "compute.googleapis.com",
        "iam.googleapis.com",
        "cloudresourcemanager.googleapis.com"
    ])
    
    service = each.key
}

# Grant the user the ability to use service accounts
# resource "google_service_account_iam_binding" "vm_sa_user" {
#   #provider = google.admin
#   for_each = google_service_account.vm_srv_acct_gen

#   service_account_id = google_project.client_projects[each.key].project_id#each.value.email
#   role               = "roles/iam.serviceAccountUser"
  
#   members = [
#     "serviceAccount:${google_service_account.vm_srv_acct_gen[each.key].email}"#"user:TheFiveEgos@gmail.com"  # Replace with your email
#   ]
# }

# Create service account for controller VM
resource "google_service_account" "controller" {
    #provider = google.admin
    account_id   = "controller-sa"
    display_name = "Controller Service Account"
    project      = google_project.controller.project_id
}

# Upload a startup as an object
# to the storage bucket

# Grant controller SA permissions to manage VMs in client projects
resource "google_project_iam_member" "controller_permissions" {
  for_each = google_project.client_projects
  #provider = google.admin
  
  project = each.value.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.controller.email}"
}

resource "google_storage_bucket" "bucket-gen-con" {
    #provider = google.admin
    name          = "${var.gcp_bucket}-con"
    location      = "US"
    storage_class = "STANDARD"
    project      = google_project.controller.project_id

    uniform_bucket_level_access = true
}

#Generate a bucket for the controller
resource "google_storage_bucket_object" "startup-con" {
    #provider = google.admin
    name         = "controller-startup.sh"
    source       = "./controller-startup.sh"
    content_type = "text/plain"
    bucket       = google_storage_bucket.bucket-gen-con.id
}

# Create controller VM
resource "google_compute_instance" "controller" {
    #provider = google.admin
    name         = "vm-controller"
    machine_type = "e2-small"
    project      = google_project.controller.project_id
    zone         = var.controller_zone

    boot_disk {
        initialize_params {
        image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = "default"
        access_config {}
    }

    service_account {
        email  = google_service_account.controller.email
        scopes = ["cloud-platform"]
    }
    metadata = {
        startup-script-url = "gs://${var.gcp_bucket}-con/controller-script.sh"
    }

}