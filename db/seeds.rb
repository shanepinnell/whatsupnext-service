# Environment-specific seeds live in db/seeds/<env>.rb. Production has none:
# bin/docker-entrypoint runs db:prepare, which seeds a fresh database, and
# self-hosted instances must start empty.
env_seeds = Rails.root.join("db/seeds/#{Rails.env}.rb")
load env_seeds if env_seeds.exist?
