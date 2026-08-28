# WhatsUpNext — Service

The Rails 8 backend for [WhatsUpNext](https://github.com/shanepinnell/whatsupnext),
a conference room display for Apple TV — room-display device
registration/pairing, calendar-source configuration, and the admin UI.
See [`SPEC.md`](https://github.com/shanepinnell/whatsupnext/blob/main/SPEC.md)
in the umbrella repo for the full architecture, data model, and API
contract.

## Status

Early. Admin login (OIDC) and the base data model exist; the admin UI
for managing rooms/buildings/devices isn't built yet.

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
bin/setup      # installs gems, prepares the database
bin/dev        # Rails server + Tailwind watcher
bin/rails test # Minitest suite
```

Secrets (Active Record encryption keys, `SECRET_KEY_BASE`, OIDC client
credentials) are never committed — this repo is public. They're
sourced from `ENV`, decrypted locally via dotenvx. See
[`CLAUDE.md`](CLAUDE.md) for the full setup.

## License

[MIT](LICENSE)
