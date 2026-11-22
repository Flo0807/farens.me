# Deploy to Coolify

GitHub Actions tests the app, builds the existing release Dockerfile, pushes it to
GHCR, and requests a Coolify deployment on pushes to `main`. Coolify is the only
deployment target. The former `WEBHOOK_URL` / `WEBHOOK_SECRET` integration is removed.

## Prepare Coolify before merging the migration

The VPS and service Compose files are managed in the separate `farens-infra`
repository. Its website Compose service runs `ghcr.io/flo0807/farens.me:main`
with `pull_policy: always`. Configure a standard Docker Compose resource on the
local Coolify server and point it to that Compose file. Do not enable a second
source-based automatic deployment: Actions must publish the image first.

Set these runtime variables in Coolify:

| Variable | Value |
|---|---|
| `WEBSITE_IMAGE` | `ghcr.io/flo0807/farens.me:main` |
| `PHX_HOST` | `farens.me` |
| `SECRET_KEY_BASE` | A persistent secret generated with `mix phx.gen.secret` |
| `PHX_SERVER` | `true` |
| `PORT` | `4000` |

Keep `SECRET_KEY_BASE` stable between deployments. Assign the domains
`https://farens.me:4000` and `https://www.farens.me:4000` to the website service in
Coolify (the port identifies the container port, not the external HTTPS port).
The existing runtime configuration allows LiveView origins for both names.
No database or persistent volume is required by this website.

Ensure the server can pull the GHCR image. Public packages need no credentials;
for a private package authenticate on the server as Coolify's SSH user with a
GitHub token granting `read:packages`. Do not use the workflow's temporary
`GITHUB_TOKEN` as a persistent server credential.

Deploy manually once and verify the home page and a LiveView navigation before
switching CI. In particular, confirm the reverse proxy supports the `/live`
WebSocket connection and that HTTPS works for both domains.

## GitHub configuration

1. Enable API access in Coolify Settings → Advanced.
2. Create a Coolify API token with **Deploy** and **Read** permissions scoped to the website resource.
3. Copy the website resource's authenticated **Deploy webhook URL**.
4. Add these repository Actions secrets:
   - `COOLIFY_WEBHOOK`: the complete HTTPS deploy webhook URL.
   - `COOLIFY_TOKEN`: the API token.
5. Merge the migration only after the target is ready. Afterwards, remove the
   unused `WEBHOOK_URL` and `WEBHOOK_SECRET` secrets.

No feature flag or legacy deployment branch remains. Both new secrets are
required. A missing secret or failed API request fails the deploy job.
The workflow has finite network timeouts and sends the token through the
Authorization header, with no redirects or automatic mutation retries.

## Verification and rollbacks

The deploy job tracks the UUID returned by Coolify and polls its status every
ten seconds. A failed or cancelled deployment fails the job. The deployment
step times out after ten minutes. Once Coolify reports `finished`, the job
checks the public homepage over HTTPS and requires HTTP 200. The Actions log
includes the deployment UUID for troubleshooting in Coolify.

`:main` is a mutable image tag. Before a release, retain the currently deployed
image digest. To roll back, set `WEBSITE_IMAGE` to
`ghcr.io/flo0807/farens.me@sha256:<previous-digest>` and redeploy in Coolify. Restore
`:main` when normal CI deployment should resume. LiveView clients reconnect
when the old application container is replaced; deployments do not preserve
in-memory sessions/process state.

Reference: [Coolify GitHub Actions documentation](https://coolify.io/docs/applications/sources/github/actions).
