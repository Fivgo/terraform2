# Create controller VM
resource "google_compute_instance" "controller" {
    
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
        startup-script-url = "gs://${var.gcp_bucket}-con/${google_storage_bucket_object.startup-con.name}"
    }

}

#setup a cluster

resource "google_compute_instance" "vm_inst_gen" {
  for_each = local.client
  
  name         = "${var.vm_config.base_name}-${each.value.name}"
  machine_type = each.value.machine_type
  zone         = each.value.zone
  project      = google_project.client_projects[each.value.name].project_id

  tags = var.vm_config.tags



  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20250113"
      size = each.value.disk.disk_size
      type = each.value.disk.disk_type
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
    shutdown-script-url = "gs://${var.gcp_bucket}-${each.value.name}/shutdown-script.sh"
  }

}

