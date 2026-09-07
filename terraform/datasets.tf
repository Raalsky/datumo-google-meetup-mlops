resource "google_bigquery_dataset" "raw" {
  project       = var.project_id
  dataset_id    = local.dataset_raw
  friendly_name = local.dataset_raw
  description   = "Transakcje płatnicze — źródło prawdy"
  location      = var.location
  labels        = local.labels
}

resource "google_bigquery_dataset" "features" {
  project       = var.project_id
  dataset_id    = local.dataset_features
  friendly_name = local.dataset_features
  description   = "Warstwa cech: migawki i widok latest"
  location      = var.location
  labels        = local.labels
}

resource "google_bigquery_dataset" "training" {
  project       = var.project_id
  dataset_id    = local.dataset_training
  friendly_name = local.dataset_training
  description   = "Artefakty treningowe: spine etykiet"
  location      = var.location
  labels        = local.labels
}
