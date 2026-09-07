# Najświeższa migawka na encję — źródło synchronizacji magazynu online.
# Inny wzorzec niż as-of join: tu moment jest zawsze "teraz", więc nie ma
# czego wybierać per wiersz.
resource "google_bigquery_table" "v_feature_values_latest" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.features.dataset_id
  table_id            = "v_feature_values_latest"
  deletion_protection = false

  view {
    use_legacy_sql = false

    query = templatefile("${path.module}/v_feature_values_latest.sql", {
      project                 = var.project_id
      features_dataset        = google_bigquery_dataset.features.dataset_id
      latest_view_window_days = local.spec.latest_view_window_days
      feature_columns         = join(",\n", [for f in local.features : "  ${f.name}"])
    })
  }

  depends_on = [google_bigquery_table.feature_values]
}
