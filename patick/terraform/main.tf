# https://registry.terraform.io/providers/heroku/heroku/latest/docs#environment-variables
terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = "2.6.1"
    }
  }
}

resource "heroku_app" "default" {
  name   = "patick"
  region = "eu"

  config_vars = {
    MIX_ENV = "prod"
  }
}

# Create a database, and configure the app to use it
resource "heroku_addon" "database" {
  app  = heroku_app.default.name
  plan = "heroku-postgresql:hobby-basic"
}

# Attach postgres credentials
resource "heroku_addon_attachment" "database_credentials" {
  app_id    = heroku_app.default.id
  addon_id  = heroku_addon.database.id
  namespace = "credential: for patick"
}

# Build code & release to the app
resource "heroku_build" "default" {
  app = heroku_app.default.name
  buildpacks = [
    "https://github.com/HashNuke/heroku-buildpack-elixir.git"
  ]

  source = {
    path    = "../patick-0.1.0.tar.gz"
    version = "0.1.0"
  }
}

# Dynamo params and build attachment
resource "heroku_formation" "default" {
  app        = heroku_app.default.name
  type       = "web"
  quantity   = 1
  size       = "free"
  depends_on = [heroku_build.default]
}

output "patick_app_url" {
  value = "https://${heroku_app.default.name}.herokuapp.com"
}
