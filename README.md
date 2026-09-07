# Cecha (nie)pospolita

Kod towarzyszący prelekcji ([Prezentacja.pdf](Prezentacja.pdf))

AS-OF join jest w [`terraform/sp_build_training_set.sql`](terraform/sp_build_training_set.sql):

```sql
AND f.feature_timestamp <= s.decision_time
AND f.feature_timestamp >  TIMESTAMP_SUB(s.decision_time, INTERVAL 10 DAY)
```

Górna granica nie pozwala ocenianej transakcji wejść do własnej cechy, dolna odcina
migawki przeterminowane, `QUALIFY` wybiera najświeższą z pozostałych.

Poza tym trzy tabele o trzech różnych ziarnach — zdarzenie, migawka cechy, decyzja —
generowane z [`terraform/feature_spec.json`](terraform/feature_spec.json).
