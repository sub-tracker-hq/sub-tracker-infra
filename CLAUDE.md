# Sub-tracker Infra

Infrastructure and CI/CD for all Sub-tracker repos.

## Contents
- local/docker-compose.yml — Postgres 16 + Redis 7
- docker/ — api + web Dockerfiles
- ci-templates/ — reusable GitHub Actions per platform
- k8s/ — production manifests (v2, don't touch yet)

## Rules
- NEVER commit real secrets. Manifests reference secret stores, not values.
- Keep CONTRIBUTING.md as the canonical branch-protection / PR setup both devs apply.

## Workflow
- Branch off `dev`, PR into `dev`. chore/infra-*, fix/infra-*