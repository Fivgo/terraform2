# create a hole in the firewall
resource "google_compute_firewall" "client-hole" {
  name    = "minecraft-allow-http-https"
  network = "default"
  for_each = local.client
  project = google_project.client_projects[each.value.name].project_id

  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
  #google_compute_instance.vm_inst_gen[each.value.name].network_interface[0].access_config[0].nat_ip
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["minecraft"]
  target_tags = ["http-server", "https-server"]
}