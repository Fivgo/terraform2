#--------CONTROLLER BUCKETS--------

resource "google_storage_bucket" "bucket-gen-con" {
    
    name          = "${var.gcp_bucket}-con"
    location      = "US"
    storage_class = "STANDARD"
    project      = google_project.controller.project_id

    uniform_bucket_level_access = true
}

#Generate a bucket for the controller
resource "google_storage_bucket_object" "startup-con" {
    name         = "controller-startup.sh"
    source       = "./materials/scripts/controller-startup.sh"
    content_type = "text/plain"
    bucket       = google_storage_bucket.bucket-gen-con.id
}



#--------CLIENT BUCKETS--------

# Create new storage bucket in the US
# location with Standard Storage

resource "google_storage_bucket" "bucket-gen" {
    
    for_each = local.client

    name          = "${var.gcp_bucket}-${each.value.name}"
    location      = "US"
    storage_class = "STANDARD"
    project       = google_project.client_projects[each.value.name].project_id

    uniform_bucket_level_access = true
}

resource "local_file" "cli_startup_script" {
  for_each = local.client

  content  = templatefile("./materials/scripts/startup-script.sh.tpl", {
    bucket_name = google_storage_bucket.bucket-gen[each.value.name].name
  })
  filename = "${path.module}/materials/scripts/startup-script-${each.key}.sh"
}

resource "local_file" "cli_mc_backup_script" {
  for_each = local.client

  content  = templatefile("./materials/scripts/startup-script.sh.tpl", {
    bucket_name = google_storage_bucket.bucket-gen[each.value.name].name
  })
  filename = "${path.module}/materials/scripts/startup-script-${each.key}.sh"
}

resource "google_storage_bucket_object" "startup-cli" {
    
    for_each = local.client
    name         = "startup-script.sh"
    source       = "${path.module}/materials/scripts/startup-script-${each.key}.sh"
    #source       = "./materials/scripts/${each.value.startup_script}"
    content_type = "text/plain"
    bucket       = google_storage_bucket.bucket-gen[each.value.name].id
}

resource "google_storage_bucket_object" "shutdown-cli" {
    
    for_each = local.client
    name         = "shutdown-script.sh"
    source       = "./materials/scripts/shutdown-script.sh"
    content_type = "text/plain"
    bucket       = google_storage_bucket.bucket-gen[each.value.name].id
}

resource "google_storage_bucket_object" "server" {
    for_each = local.client
    name         = "${each.value.file_path}"
    source       = "./materials/${each.value.file_path}"
    content_type = "text/plain"
    bucket       = google_storage_bucket.bucket-gen[each.value.name].id
}
