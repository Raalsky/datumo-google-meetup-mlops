SELECT
  entity_id,
  feature_timestamp,
${feature_columns}
FROM `${project}.${features_dataset}.feature_values`
-- Wymaganie `require_partition_filter` i optymalizacja kosztowa
WHERE feature_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL ${latest_view_window_days} DAY)
-- Po jednym wpisie na encję
QUALIFY ROW_NUMBER() OVER (PARTITION BY entity_id ORDER BY feature_timestamp DESC) = 1
