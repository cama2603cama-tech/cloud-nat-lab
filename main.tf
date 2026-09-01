# 1. VPC Única
resource "google_compute_network" "custom_vpc" {
  name                    = "private-access-vpc"
  auto_create_subnetworks = false
}

# 2. Subred US-West1 (Con Private Google Access HABILITADO)
resource "google_compute_subnetwork" "subnet_us_west1" {
  name                     = "subnet-us-west1"
  ip_cidr_range            = "10.240.0.0/24"
  region                   = var.region_us_west
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true
}

# 3. Subred US-East1 (Con Private Google Access DESHABILITADO)
resource "google_compute_subnetwork" "subnet_us_east1" {
  name                     = "subnet-us-east1"
  ip_cidr_range            = "192.168.1.0/24"
  region                   = var.region_us_east
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = false
}

# 4. Cloud Router y Cloud NAT para us-east1 (o la región que lo requiera para salir a internet general)
resource "google_compute_router" "router_us_east1" {
  name    = "router-us-east1"
  region  = var.region_us_east
  network = google_compute_network.custom_vpc.id
}

resource "google_compute_router_nat" "nat_us_east1" {
  name                               = "nat-us-east1"
  router                             = google_compute_router.router_us_east1.name
  region                             = google_compute_router.router_us_east1.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Configuración de Logs para Cloud NAT
  log_config {
    enable = true
    filter = "ALL" # Opciones: "ERRORS_ONLY", "TRANSLATIONS_ONLY", o "ALL"
  }
}

# 5. Regla de Firewall para SSH via IAP (35.235.240.0/20) para toda la red
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-ssh-iap"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [
    google_compute_network.custom_vpc
  ]

  source_ranges = ["35.235.240.0/20"]
  target_tags   = [] # Sin tags, aplica a todas las VMs de la red por defecto
}

# 6. Región us-west1 (A1 sin IP pública, A2 con IP pública)
resource "google_compute_instance" "vm_a1" {
  name         = "vm-a1-private"
  machine_type = var.machine_type
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_us_west1.id
    # Sin network_access (nat_ip), por lo que NO tendrá IP pública
  }
}

resource "google_compute_instance" "vm_a2" {
  name         = "vm-a2-public"
  machine_type = var.machine_type
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_us_west1.id
    access_config {
      // Bloque vacio para que GCP asigne automaticamente una IP publica efimera
    }
  }
}

# 7. Región us-east1 (B1 sin IP pública, B2 con IP pública)
resource "google_compute_instance" "vm_b1" {
  name         = "vm-b1-private"
  machine_type = var.machine_type
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_us_east1.id
    # Sin IP pública
  }
}

resource "google_compute_instance" "vm_b2" {
  name         = "vm-b2-public"
  machine_type = var.machine_type
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_us_east1.id
    access_config {
      // IP pública efímera
    }
  }
}

# 8. Bucket
resource "google_storage_bucket" "my_bucket" {
  name          = "gcp-terraform-secure-bucket-${var.project_id}"
  location      = "US" # Multi-región que une todo EEUU
  force_destroy = true

  public_access_prevention = "enforced"
}

#resource "google_storage_bucket_object" "access_file" {
#  name   = "access.svg"
#  bucket = google_storage_bucket.my_bucket.name
#  source = "https://storage.googleapis.com/cloud-training/gcpnet/private/access.svg"
#}