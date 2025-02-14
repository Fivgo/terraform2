#--------CONTROLLER PERMISSIONS--------

# Create service account for controller VM
resource "google_service_account" "controller" {
    
    account_id   = "controller-sa"
    display_name = "Controller Service Account"
    project      = google_project.controller.project_id
}

# Grant controller SA permissions to manage VMs in client projects
resource "google_project_iam_member" "controller_permissions" {
  for_each = google_project.client_projects
  
  
  project = each.value.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.controller.email}"
}

resource "google_storage_bucket_iam_member" "bucket_admin_access_con" {

    bucket  = google_storage_bucket.bucket-gen-con.name
    role    = "roles/storage.admin" # need admin role because each vm needs c,w,and d
    member  = "serviceAccount:${google_service_account.controller.email}"
}

#--------CLIENT PERMISSIONS--------

# Create a new service account for the VM
resource "google_service_account" "vm_srv_acct_gen" {
    
    for_each = local.client
    project = google_project.client_projects[each.value.name].project_id
    account_id   = "vsa${each.value.name}"
    display_name = "Service Account for my ${each.value.name_tx}"
}

resource "google_storage_bucket_iam_member" "bucket_admin_access" {
    
    for_each = local.client

    bucket  = google_storage_bucket.bucket-gen[each.value.name].name
    role    = "roles/storage.admin" # need admin role because each vm needs c,w,and d
    member  = "serviceAccount:${google_service_account.vm_srv_acct_gen[each.value.name].email}"
}

# # Grant the user the ability to use service accounts
# resource "google_service_account_iam_binding" "vm_sa_user" {
  
#   for_each = local.client

#   service_account_id = "projects/${google_project.client_projects[each.value.name].project_id}/serviceAccounts/${google_service_account.vm_srv_acct_gen[each.value.name].email}"
#   role               = "roles/iam.serviceAccountUser"
  
#   members = [
#     "user:TheFiveEgos@gmail.com"  # Replace with your email
#   ]
# }