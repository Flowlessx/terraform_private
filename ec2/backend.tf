# --- root/backend.tf ---
terraform {
  backend "s3" {
    bucket = "asg-highstreet"
    key    = "remote.tfstate"
    region = "eu-central-1"
  }
}