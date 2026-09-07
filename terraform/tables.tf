resource "google_bigquery_table" "transactions" {
  project       = var.project_id
  dataset_id    = google_bigquery_dataset.raw.dataset_id
  table_id      = "transactions"
  friendly_name = "Transakcje"
  description   = "Transakcje płatnicze"
  labels        = local.labels

  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "event_time"
  }
  require_partition_filter = true
  clustering               = ["user_id"]

  schema = jsonencode([
    { name = "txn_id", type = "STRING", mode = "REQUIRED", description = "Identyfikator transakcji" },
    { name = "user_id", type = "STRING", mode = "REQUIRED", description = "Identyfikator użytkownika" },
    { name = "event_time", type = "TIMESTAMP", mode = "REQUIRED", description = "Moment zdarzenia" },
    { name = "amount", type = "FLOAT", mode = "REQUIRED", description = "Kwota transakcji" },
    { name = "payment_channel", type = "STRING", mode = "REQUIRED", description = "Kanał płatności" },
  ])
}

resource "google_bigquery_table" "feature_values" {
  project       = var.project_id
  dataset_id    = google_bigquery_dataset.features.dataset_id
  table_id      = "feature_values"
  friendly_name = "Migawki cech"
  description   = "Historia cech użytkownika. Wiersz = (encja, moment przeliczenia)."
  labels        = local.labels

  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "feature_timestamp"
  }
  require_partition_filter = true
  clustering               = ["entity_id"]

  schema = jsonencode(concat([
    { name = "entity_id", type = "STRING", mode = "REQUIRED", description = "Klucz encji" },
    { name = "feature_timestamp", type = "TIMESTAMP", mode = "REQUIRED", description = "Moment przeliczenia" },
    ], [
    for f in local.features : {
      name        = f.name
      type        = f.type == "FLOAT64" ? "FLOAT" : f.type
      mode        = "NULLABLE"
      description = local.opis_cechy[f.name]
    }
  ]))
}

resource "google_bigquery_table" "fraud_labels" {
  project       = var.project_id
  dataset_id    = google_bigquery_dataset.training.dataset_id
  table_id      = "fraud_labels"
  friendly_name = "Spine etykiet"
  description   = "Tabela etykiet transakcji"
  labels        = local.labels

  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "decision_time"
  }
  require_partition_filter = true
  clustering               = ["entity_id"]

  schema = jsonencode([
    { name = "txn_id", type = "STRING", mode = "REQUIRED", description = "Identyfikator transakcji" },
    { name = "entity_id", type = "STRING", mode = "REQUIRED", description = "Encja" },
    { name = "decision_time", type = "TIMESTAMP", mode = "REQUIRED", description = "Moment autoryzacji" },
    { name = "label", type = "BOOLEAN", mode = "REQUIRED", description = "Czy transakcja okazała się nadużyciem" },
  ])
}
