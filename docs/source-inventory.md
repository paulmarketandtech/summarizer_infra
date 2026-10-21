```bash
docker compose exec -T db psql -U postgres -d summarizer -c "
  SELECT relname, n_live_tup FROM pg_stat_user_tables ORDER BY n_live_tup DESC;"

docker compose exec -T db psql -U postgres -d summarizer -c "
  SELECT indexname, indexdef FROM pg_indexes WHERE schemaname='public';"

docker compose exec -T db psql -U postgres -d summarizer -c "
  SELECT 'single_stock_summary' t, vector_dims(embedding) d FROM single_stock_summary LIMIT 1
  UNION ALL SELECT 'transcript_chunks', vector_dims(embedding) FROM transcript_chunks LIMIT 1
  UNION ALL SELECT 'transcript_summaries', vector_dims(embedding) FROM transcript_summaries LIMIT 1;"
```
