variable "project_id" {
  type        = string
  description = "ID del proyecto en GCP"
  default     = "gcp-terraform-secure-vpc"
}

variable "region_us_west" {
  type        = string
  description = "Región EEUU Oeste"
  default     = "us-west1"
}

variable "region_us_east" {
  type        = string
  description = "Región EEUU Este"
  default     = "us-east1"
}

variable "machine_type" {
  type        = string
  description = "Tipo de instancia económico para las VMs"
  default     = "e2-micro"
}