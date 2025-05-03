## Introduction

This repo is used just for learning purposes to spin up a basic EKS cluster.

## Usage

if you'd like to use this repo, note that your EKS cluster & VPC resources would be prefixed with your IAM username, however please remember to change the terraform backend configs in ```backend.tf```

```hcl
terraform {
  backend "s3" {
    bucket = ""               #Update accordingly
    key    = "<name>.tfstate" #Update accordingly
    region = ""               #Update accordingly
  }
}
```