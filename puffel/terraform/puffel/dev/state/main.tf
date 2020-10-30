provider "google" {
  project = "puffel-dev"
  region  = "europe-west2"
  zone    = "europe-west2a"
}

resource "google_storage_bucket" "remote_state" {
  name          = "gilacost-tf-state"
  location      = "EU"
  force_destroy = true
}
