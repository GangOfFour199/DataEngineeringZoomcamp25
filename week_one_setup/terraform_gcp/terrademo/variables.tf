variable "credentials" {
  description = "My Credentials"
  default     = "./keys/my-creds.json"
}

variable "project_name" {
  description = "Name of Project"
  default     = "terraform-demo-457811"
}

variable "bq_dataset_name" {
  description = "Name of BigQuery Dataset"
  default     = "example_dataset"
}

variable "location" {
  description = "Geographic location of Project"
  default     = "EUROPE-WEST2"
}

variable "region" {
  description = "Geographic region location of Project"
  default     = "europe-west2-a"
}

variable "gcs_bucket_name" {
  description = "Name of Google Cloud Storage Bucket"
  default     = "demo-457811-tf-bucket"
}

variable "gcs_storage_class" {
  description = "Class of Bucket Storage"
  default     = "STANDARD"
}