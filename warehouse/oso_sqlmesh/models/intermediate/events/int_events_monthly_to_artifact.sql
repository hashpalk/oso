MODEL (
  name oso.int_events_monthly_to_artifact,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column bucket_week,
    batch_size 365,
    batch_concurrency 1,
    lookback 1
  ),
  start '2015-01-01',
  cron '@daily',
  partitioned_by (DAY("bucket_week"), "event_source", "event_type"),
  grain (bucket_day, event_type, event_source, from_artifact_id, to_artifact_id),
  enabled false,
  audits (
    not_null(columns := (event_type, event_source)),
  ),
  ignored_rules (
    "incrementalmustdefinenogapsaudit",
  )
);

SELECT
  DATE_TRUNC('WEEK', bucket_day) AS bucket_week,
  to_artifact_id,
  from_artifact_id,
  event_source,
  event_type,
  SUM(amount)
FROM oso.int_events_daily_to_artifact
WHERE
  bucket_day BETWEEN @start_date AND @end_date
GROUP BY
  1,
  from_artifact_id,
  to_artifact_id,
  event_source,
  event_type