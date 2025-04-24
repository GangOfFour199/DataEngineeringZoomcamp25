terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.31.0"
    }
  }
}

provider "google" {
  project = "terraform-demo-457811"
  region  = "europe-west2-a"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "demo-457811-tf-bucket"
  location      = "EUROPE-WEST2"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}