# --- Región us-west1 ---
output "vm_a1_internal_ip" {
  description = "IP interna de A1 (sin IP pública)"
  value       = google_compute_instance.vm_a1.network_interface[0].network_ip
}

output "vm_a2_ips" {
  description = "IPs de A2 (Privada y Pública)"
  value = {
    internal_ip = google_compute_instance.vm_a2.network_interface[0].network_ip
    public_ip   = google_compute_instance.vm_a2.network_interface[0].access_config[0].nat_ip
  }
}

# --- Región us-east1 ---
output "vm_b1_internal_ip" {
  description = "IP interna de B1 (sin IP pública)"
  value       = google_compute_instance.vm_b1.network_interface[0].network_ip
}

output "vm_b2_ips" {
  description = "IPs de B2 (Privada y Pública)"
  value = {
    internal_ip = google_compute_instance.vm_b2.network_interface[0].network_ip
    public_ip   = google_compute_instance.vm_b2.network_interface[0].access_config[0].nat_ip
  }
}