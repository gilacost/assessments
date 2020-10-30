terraform {
  backend "gcs" {
    bucket = "gilacost-tf-state"
    prefix = "terraform/puffel/dev"
  }
}

provider "google" {
  project = "puffel-dev"
  region  = "europe-west2"
  zone    = "europe-west2a"
}

resource "google_pubsub_topic" "default" {
  name = "puffel-dev-topic"

  labels = {
    env = "dev"
  }
}

resource "google_pubsub_subscription" "default" {
  name  = "puffel-dev-subscription"
  topic = google_pubsub_topic.default.name

  labels = {
    env = "dev"
  }

  message_retention_duration = "1200s"
  retain_acked_messages      = true
  ack_deadline_seconds       = 20
  expiration_policy {
    ttl = "300000.5s"
  }
}
