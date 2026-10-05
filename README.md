# WhatsUpNext — Service

The Rails 8 backend for [WhatsUpNext](https://github.com/shanepinnell/whatsupnext),
a conference room display for Apple TV — room-display device
registration/pairing, calendar-source configuration, and the admin UI.
See [`SPEC.md`](https://github.com/shanepinnell/whatsupnext/blob/main/SPEC.md)
in the umbrella repo for the full architecture, data model, and API
contract.

## Status

Early. Admin login (OIDC), the base data model, and CRUD for the
physical hierarchy (sites/buildings/floors/rooms) exist; device
pairing/management isn't built yet.

## Stack

- Ruby 4.0.5 (`.ruby-version`), Rails 8
- SQLite + Solid Queue / Solid Cache / Solid Cable — no external
  datastore dependency, keeps this self-hostable as a single Docker
  image
- Tailwind CSS
- Kamal (Docker + SSH to any host) for deploys

## Authentication

Admin UI login is OpenID Connect only, no passwords. Each deployed
instance configures one OIDC provider (Google Workspace, Entra ID,
Okta, Auth0, etc.) via environment variables — see `SPEC.md`'s
Authentication section.

## Local development

```
bin/setup                  # installs gems, prepares the database
bin/dev                    # Rails server + Tailwind watcher
bin/unlock bin/rails test  # Minitest suite (needs decrypted secrets)
```

Secrets (Active Record encryption keys, `SECRET_KEY_BASE`, OIDC client
credentials) are never committed — this repo is public. They're
sourced from `ENV`, decrypted locally via dotenvx. See
[`CLAUDE.md`](CLAUDE.md) for the full setup.

### Mock OIDC provider

Admin login needs a reachable OIDC provider matching `OIDC_ISSUER`.
Locally, use a mock server rather than a real IdP —
[`oidc-server-mock`](https://github.com/Soluto/oidc-server-mock) via
Docker Compose. Its config lives outside this repo (it's per-developer
tooling, not part of the app), e.g. in `~/services/oidc-mock/`:

- `docker-compose.yml` — runs `ghcr.io/soluto/oidc-server-mock` on
  `https://localhost:8443`, mounting the files below
- `clients.json` — one client whose ID/secret match `OIDC_CLIENT_ID` /
  `OIDC_CLIENT_SECRET`, with redirect URI
  `http://localhost:3000/auth/openid_connect/callback` and scopes
  `openid email profile`
- `users.json` — test login(s), each with `email` and
  `email_verified` claims
- a TLS cert/key for `localhost` (e.g. from `mkcert localhost
  127.0.0.1 ::1`), so Ruby's HTTP client trusts the issuer

Start it before testing login:

```
docker compose -f ~/services/oidc-mock/docker-compose.yml up -d
```

and confirm it's up by curling
`$OIDC_ISSUER/.well-known/openid-configuration`. A
`Connection refused` there means the mock server isn't running, not
an app bug.

## License

[MIT](LICENSE)
