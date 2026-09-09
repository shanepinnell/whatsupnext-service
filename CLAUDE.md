# CLAUDE.md — the Service

See the root `CLAUDE.md` (`../CLAUDE.md`) for project-wide working style
and development practices — this file only covers what's specific to
this repository.

## Development practices (Service-specific)

- **Testing framework**: Minitest (Rails' default), not RSpec.
- **Scaffolding**: prefer Rails' built-in generators (models, migrations,
  controllers, views, `scaffold_controller`, etc.) over hand-writing files
  from scratch — edit/extend generator output rather than writing it by
  hand. This includes routes: let a generator add its own route entry
  first, then hand-adjust nesting/shallow structure afterward, rather
  than hand-authoring `routes.rb` entries upfront.
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
  - **The decryption key (`DOTENV_PRIVATE_KEY`) lives in whatever local
    secret manager you already have, not as a file anywhere** — generated
    as a byproduct of the `encrypt` step above (in `.env.keys`), stored
    once (macOS Keychain's `security add-generic-password`, Linux's
    `secret-tool store`, a password manager CLI — pick whatever's
    actually installed), then `.env.keys` is deleted. Deliberately not
    tied to one specific tool: this repo ships to self-hosting customers
    on whatever OS they run, and `dotenvx` itself only cares that
    `DOTENV_PRIVATE_KEY` ends up in the environment, not how it got
    there. The secret manager is genuinely separate from the
    repo/filesystem-backup risk the encrypted `.env` itself is protected
    against by encryption — this is the one thing that must never be
    co-located with the ciphertext it decrypts, or the encryption is
    theater (see: why `config/master.key` sitting next to
    `credentials.yml.enc` in the same directory doesn't actually protect
    it either).
  - **Running commands with the decrypted secrets**: `bin/unlock` looks
    up `DOTENV_PRIVATE_KEY` (tries macOS Keychain via `security`, then
    Linux's `secret-tool`, whichever is actually installed) and runs the
    given command through `dotenvx run --`:
    ```
    bin/unlock bin/rails test
    bin/unlock bin/dev
    ```
    If neither known secret store is found, `bin/unlock` doesn't fail
    silently — it prints the manual fallback so you can export
    `DOTENV_PRIVATE_KEY` yourself from whatever secret manager you
    actually use, then run `dotenvx run --` directly:
    ```
    DOTENV_PRIVATE_KEY=$(<your retrieval command>) dotenvx run -- bin/rails test
    ```
  - See `config/initializers/active_record_encryption.rb` for which env
    vars `.env` needs to contain.

See `../SPEC.md` (the umbrella repo) for the actual product architecture,
data model, and API contract.
