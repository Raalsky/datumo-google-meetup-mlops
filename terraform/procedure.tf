resource "google_bigquery_routine" "sp_build_training_set" {
  project      = var.project_id
  dataset_id   = google_bigquery_dataset.training.dataset_id
  routine_id   = "sp_build_training_set"
  routine_type = "PROCEDURE"
  language     = "SQL"
  description  = "Buduje training_set as-of joinem. sync_lag_seconds symuluje opóźnienie synchronizacji."

  arguments {
    name      = "sync_lag_seconds"
    data_type = jsonencode({ typeKind = "INT64" })
  }

  definition_body = templatefile("${path.module}/sp_build_training_set.sql", {
    project          = var.project_id
    training_dataset = google_bigquery_dataset.training.dataset_id
    features_dataset = google_bigquery_dataset.features.dataset_id
    raw_dataset      = google_bigquery_dataset.raw.dataset_id
    kolumny          = local.kolumny_training_set
    feature_select   = local.feature_select
    request_select   = local.request_select
    horizon_days     = local.spec.training_horizon_days
    max_age_seconds  = local.max_age_seconds
  })

  depends_on = [
    google_bigquery_table.fraud_labels,
    google_bigquery_table.feature_values,
    google_bigquery_table.transactions,
  ]
}
