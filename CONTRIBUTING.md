# Contributing to Sub-tracker

Onboarding and working conventions for the Sub-tracker product. This guide is
**editor-neutral** — use VSCode, a JetBrains IDE, or the plain CLI. The project
config works identically across all of them.

---

## 1. The product at a glance

Sub-tracker is a cross-platform subscription manager. EU-first (Tink / PSD2),
with phased expansion planned (EU → US → India → Korea/Japan).

It spans **five independent repositories**:

| Repo | Stack | Role |
|------|-------|------|
| `sub-tracker-api` | Go + Chi + sqlc | **The contract.** All clients consume it. |
| `sub-tracker-web` | Next.js 14 + TypeScript | Web frontend |
| `sub-tracker-ios` | Swift + SwiftUI | Native iOS app |
| `sub-tracker-android` | Kotlin + Jetpack Compose | Native Android app |
| `sub-tracker-infra` | Docker, CI/CD, K8s | Infrastructure (this repo) |

The API is the source of truth. Its `api/openapi.yaml` and `db/migrations`
define the data shapes; web, iOS, and Android must follow them.

---

## 2. Recommended folder layout

Clone all five repos as **siblings under one umbrella folder**. The umbrella is
just a folder — *not* a git repo. Each subfolder remains its own independent
repo with its own remote and branches.

```
sub-tracker/                  <- umbrella folder (open THIS in your editor)
├── sub-tracker-api/
├── sub-tracker-web/
├── sub-tracker-ios/
├── sub-tracker-android/
└── sub-tracker-infra/
```

```bash
mkdir sub-tracker && cd sub-tracker
git clone https://github.com/sub-tracker-hq/sub-tracker-api
git clone https://github.com/sub-tracker-hq/sub-tracker-web
git clone https://github.com/sub-tracker-hq/sub-tracker-ios
git clone https://github.com/sub-tracker-hq/sub-tracker-android
git clone https://github.com/sub-tracker-hq/sub-tracker-infra
```

Opening the umbrella folder lets Claude Code see all five repos at once (useful
for coordinated changes). For focused work on one repo, open just that repo so
the context stays tight.

---

## 3. Toolchain

Install once per machine.

**Core (needed for the API repo):**
- **Go** (latest stable)
- **Docker Desktop** — must be running before `make db-up`
- **sqlc** — `go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest`
- **golang-migrate** — `go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest`
- **air** (hot reload) — `go install github.com/air-verse/air@latest`
- **make** — Linux/macOS have it; on Windows: `winget install GnuWin32.Make`

Ensure `$(go env GOPATH)/bin` is on your `PATH`.

**For Claude Code (any editor):**
- **Node.js** (the Claude Code CLI ships via npm and the IDE plugins require it)
- **Claude Code CLI** — `npm install -g @anthropic-ai/claude-code`
  - This is a global tool install, not a project dependency. It adds nothing to
    the Go repo.

**Per-client (only if working on that repo):**
- web → Node + `pnpm`
- ios → macOS + Xcode (Swift Package Manager, no CocoaPods)
- android → Android Studio + JDK (Gradle via `./gradlew`)

---

## 4. Editor + Claude Code setup (pick one)

All Claude config (`CLAUDE.md`, `.claudeignore`, `.claude/settings.json`) is
committed in each repo and read by the Claude Code engine itself — **not** by any
specific editor. So Claude behaves identically regardless of your choice below.

**Option A — VSCode extension**
Extensions view (`Ctrl/Cmd+Shift+X`) → search "Claude Code" (publisher:
anthropic) → Install. Requires VSCode 1.98.0+. Open the panel via the spark icon
or Command Palette → `Claude Code: Open`.

**Option B — JetBrains plugin** (IntelliJ IDEA, GoLand, Android Studio, etc.)
Settings → Plugins → Marketplace → search "Claude Code" → Install. Natural fit:
GoLand for the API, Android Studio for the Android repo.

**Option C — CLI only**
Run `claude` in any repo directory, including inside your IDE's integrated
terminal. Editor-independent.

**All options require:**
- Your own Claude subscription (Pro / Max / Team) — auth is per-person
- The Claude Code CLI installed (the IDE plugins need it present)

On first launch you'll sign in through the browser.

---

## 5. Branch & PR workflow

```
main       <- protected release gate. PR + 1 approval required.
dev         <- integration branch. Default branch. Both devs push here via PRs.
feature/*   <- branched off dev
fix/*
chore/*
```

Branch naming uses a repo-area prefix:
`feature/api-subscription-crud`, `fix/web-dashboard-layout`,
`chore/infra-ci-pipeline`, etc.

**Daily flow:**
```bash
git checkout dev && git pull
git checkout -b feature/api-<thing>
# ... work, commit ...
git push -u origin feature/api-<thing>
# open PR -> dev
```

`dev` is unprotected (trust-based integration). `main` is the quality gate —
PRs into `main` require a review.

---

## 6. Project conventions (all repos)

- **Money** is `NUMERIC(12,2)` in SQL, `Decimal`/`BigDecimal` in code — **never
  floats**, on any platform.
- **Currency** is ISO 4217 (`EUR` default).
- **Never store full IBANs** — last 4 digits only.
- **GDPR**: user deletion cascades all related data.
- Client type/model definitions **mirror the API contract** — don't invent
  response shapes; match `sub-tracker-api/api/openapi.yaml`.

---

## 7. Claude config: what's committed vs. ignored

| File | Committed? | Why |
|------|-----------|-----|
| `CLAUDE.md` | Yes | Shared project context |
| `.claudeignore` | Yes | Repo-wide ignore rules |
| `.claude/settings.json` | Yes | Shared tool permissions |
| `.claude/settings.local.json` | **No (gitignored)** | Personal machine overrides |

Never put secrets in `CLAUDE.md` — it's committed and visible to anyone with
repo access.

---

## 8. Common setup gotchas

- **`make: command not found` (Windows)** → install via `winget install
  GnuWin32.Make`, or run the underlying command directly.
- **Docker pipe error on `make db-up`** → Docker Desktop isn't running. Launch it
  and wait for the tray icon to settle.
- **`password authentication failed for user "dev"`** → a stale Postgres volume,
  or a local Postgres service occupying port 5432. Fix: `docker compose down -v
  && docker compose up -d`, and/or stop the conflicting local Postgres service.
- **Claude panel blank on first open (Windows/VSCode)** → known webview cache
  quirk; close the editor, clear the Claude Code webview cache, reopen.

---

## 9. First-run sanity check

```bash
cd sub-tracker-api
cp .env.example .env
make db-up                 # needs Docker Desktop running
make migrate-up
docker compose exec postgres psql -U dev -d subtracker -c "\dt"
# -> should list 7 tables + schema_migrations
```

If that works, you're set. Open the repo (or the umbrella folder) in your editor,
start Claude Code, and ask it to summarize the project to confirm the `CLAUDE.md`
files are loading.