locals {
  spec     = jsondecode(file("${path.module}/feature_spec.json"))
  features = local.spec.online_features

  dataset_raw      = "fraud_raw"
  dataset_features = "fraud_features"
  dataset_training = "fraud_training"

  labels = {
    owner   = "zespol-risk"
    purpose = "feature-store-demo"
  }

  # TTL wartości: najdłuższy dopuszczalny wiek migawki w as-of joinie.
  max_age_seconds = max([for f in local.features : f.max_age_seconds]...)

  # Opis kolumny cechy: znaczenie plus okno wyrażone w dniach.
  opis_cechy = { for f in local.features :
  f.name => "${f.opis}. Okno ${f.window_seconds / 86400} dni." }

  # Kolumny training_set. Tabelę tworzy procedura przez CREATE OR REPLACE TABLE
  kolumny_training_set = join(",\n", concat(
    [
      "  txn_id            STRING    OPTIONS(description = \"Identyfikator transakcji\")",
      "  entity_id         STRING    OPTIONS(description = \"Klucz encji\")",
      "  decision_time     TIMESTAMP OPTIONS(description = \"Moment autoryzacji\")",
      "  label             BOOL      OPTIONS(description = \"Czy transakcja okazała się nadużyciem\")",
      "  feature_timestamp TIMESTAMP OPTIONS(description = \"Moment przeliczenia\")",
    ],
    [for f in local.features :
    "  ${f.name} ${f.type} OPTIONS(description = \"${local.opis_cechy[f.name]}\")"],
    [for f in local.spec.request_features :
    "  ${f.name} ${f.type} OPTIONS(description = \"${f.opis}\")"],
  ))

  feature_select = join(",\n", [for f in local.features : "  f.${f.name}"])
  request_select = join(",\n", [for f in local.spec.request_features : "  r.${f.name}"])
}
