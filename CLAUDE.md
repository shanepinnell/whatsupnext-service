# CLAUDE.md — the Service

See the root `CLAUDE.md` (`../CLAUDE.md`) for project-wide working style
and development practices — this file only covers what's specific to
this repository.

## Development practices (Service-specific)

- **Testing framework**: Minitest (Rails' default), not RSpec.
- **Scaffolding**: prefer Rails' built-in generators (models, migrations,
  etc.) over hand-writing files from scratch — edit/extend generator
  output rather than writing it by hand.
- **Local secrets (Active Record encryption keys, etc.)**: never in
  `credentials.yml.enc` — this repo is public. Sourced from `ENV` in
  every environment; production gets them from Kamal secrets. For local
  dev/test, use `dotenvx` (not `dotenv-rails` — no gem/Gemfile
  footprint, since this app ships to self-hosting customers and
  shouldn't carry any `.env`-loading convention they could mistake for a
  production pattern).
  - Setup: `curl -sfS https://dotenvx.sh | sh && dotenvx ext precommit --install`.
  - **`service/.env` holds real values only encrypted** — created once via
    `dotenvx encrypt -f .env` (converts plaintext values to ciphertext in
    place). Encrypted, it's safe to sit inside the repo, gitignored as a
    second layer. Plain gitignoring alone isn't enough on its own: it
    only guards a `git add`/`git commit`, not the `service/` directory
    becoming public some other way (zipped for a backup, synced to cloud
    storage) — encryption is what actually makes that safe, not the
    directory it happens to live in.
  - **The decryption key (`DOTENV_PRIVATE_KEY`) lives in macOS Keychain,
    not as a file anywhere** — generated as a byproduct of the `encrypt`
    step above (in `.env.keys`), stored once via `security
    add-generic-password -U -a whatsupnext-service -s
    whatsupnext-dotenvx-key -w`, then `.env.keys` is deleted. Keychain is
    genuinely separate from the repo/filesystem-backup risk the encrypted
    `.env` itself is protected against by encryption — this is the one
    thing that must never be co-located with the ciphertext it decrypts,
    or the encryption is theater (see: why `config/master.key` sitting
    next to `credentials.yml.enc` in the same directory doesn't actually
    protect it either).
  - Retrieve and run via a personal shell function (in your own
    `~/.zshrc`, not part of this repo):
    ```
    wun-rails() {
      DOTENV_PRIVATE_KEY=$(security find-generic-password -a whatsupnext-service -s whatsupnext-dotenvx-key -w 2>/dev/null) \
        dotenvx run -- bin/rails "$@"
    }
    ```
    Usage: `wun-rails test`, `wun-rails server`, `wun-rails console`.
  - See `config/initializers/active_record_encryption.rb` for which env
    vars `.env` needs to contain.

See `../SPEC.md` (the umbrella repo) for the actual product architecture,
data model, and API contract.
