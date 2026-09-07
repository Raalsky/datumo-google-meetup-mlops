variable "project_id" {
  description = "Projekt GCP, w którym powstaną datasety."
  type        = string
}

variable "region" {
  description = "Region zasobów."
  type        = string
  default     = "europe-west1"
}

variable "location" {
  description = "Lokalizacja datasetów BigQuery. Regionalna, nie multiregion."
  type        = string
  default     = "europe-west1"
}
