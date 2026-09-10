Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :openid_connect,
    issuer: ENV.fetch("OIDC_ISSUER"),
    discovery: true,
    scope: [ :openid, :email ],
    client_options: {
      identifier: ENV.fetch("OIDC_CLIENT_ID"),
      secret: ENV.fetch("OIDC_CLIENT_SECRET"),
      redirect_uri: "#{Rails.env.development? ? "http" : "https"}://#{ENV["SERVICE_HOST"]}/auth/openid_connect/callback"
    }
end
