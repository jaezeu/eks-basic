terraform {
  backend "s3" {
    bucket = ""               #Update accordingly
    key    = "<name>.tfstate" #Update accordingly
    region = ""               #Update accordingly
  }
}