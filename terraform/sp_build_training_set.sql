CREATE OR REPLACE TABLE `${project}.${training_dataset}.training_set` (
${kolumny}
)
PARTITION BY DATE(decision_time)
CLUSTER BY entity_id
OPTIONS(description = "Zbiór treningowy: wiersz na decyzję, cechy dołączone as-of joinem")
AS
SELECT
  s.txn_id,
  s.entity_id,
  s.decision_time,
  s.label,
  f.feature_timestamp,
${feature_select},
${request_select}
FROM `${project}.${training_dataset}.fraud_labels` AS s
-- AS-OF JOIN
JOIN `${project}.${raw_dataset}.transactions` AS r
  ON r.txn_id = s.txn_id
JOIN `${project}.${features_dataset}.feature_values` AS f
  ON f.entity_id = s.entity_id
-- Reguła wyboru migawki: najświeższa NIE PÓŹNIEJSZA niż moment decyzji
-- i nie starsza niż TTL. Moment odcięcia cofnięty o sync_lag_seconds — tak
-- wygląda wartość, którą serwowanie NAPRAWDĘ ma w chwili decyzji.
  AND f.feature_timestamp <= TIMESTAMP_SUB(s.decision_time, INTERVAL sync_lag_seconds SECOND)
  AND f.feature_timestamp >  TIMESTAMP_SUB(s.decision_time, INTERVAL sync_lag_seconds + ${max_age_seconds} SECOND)
-- Obie tabele są partycjonowane, optymalizacja kosztowa
WHERE s.decision_time     >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL ${horizon_days} DAY)
  AND f.feature_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL ${horizon_days} DAY)
  AND r.event_time        >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL ${horizon_days} DAY)
-- Najświeższa migawka spełniająca warunek
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY s.txn_id ORDER BY f.feature_timestamp DESC
) = 1
