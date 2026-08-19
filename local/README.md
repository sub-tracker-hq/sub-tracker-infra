# Local dev environment

`docker-compose.yml` here runs Postgres 16 + Redis 7 for local development
against sub-tracker-api. Matches the same setup sub-tracker-api's own
docker-compose.yml uses for its `make db-up`.

```bash
docker compose -f local/docker-compose.yml up -d
```
