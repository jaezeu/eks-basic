# EKS Basic (Terraform)

This repository provisions a basic Amazon EKS cluster and VPC for learning.

Resource names are automatically prefixed using your current AWS identity (derived from your IAM ARN), so different users can apply the same code without name collisions.

## What this creates

- VPC (CIDR `172.31.0.0/16`) with public and private subnets
- Single NAT gateway
- EKS cluster (`1.33`) with public endpoint enabled
- One managed node group (`t3.micro`, desired size `3`)
- Core EKS addons (`coredns`, `kube-proxy`, `vpc-cni`, `eks-pod-identity-agent`)

## Prerequisites

- Terraform `>= 1.5` (recommended)
- AWS account and IAM permissions to create EKS, EC2, IAM, and VPC resources
- AWS credentials configured locally (for example via AWS CLI profile/env vars)
- `kubectl` and `helm` (for sample app deployment)

## Configure before first apply

1. Update Terraform backend in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = ""               # Update accordingly
    key    = "<name>.tfstate" # Update accordingly
    region = ""               # Update accordingly
  }
}
```

2. Set the AWS region variable (default is `ap-southeast-1`) in `variable.tf`:

```hcl
variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-southeast-1"
}
```

Recommended: set your own value in `terraform.tfvars`:

```hcl
region = "ap-southeast-1"
```

## Deploy

```bash
terraform init
terraform plan -var="region=ap-southeast-1"
terraform apply -var="region=ap-southeast-1"
```

## Connect to the cluster

After apply, configure kubeconfig using the same region value you used for Terraform:

```bash
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name "$(terraform output -raw cluster_name)"
```

Quick verification:

```bash
kubectl get nodes
kubectl get ns
```

## Sample apps

Two sample Helm workloads are included under `sample-apps/`.

### PostgreSQL

```bash
cd sample-apps/postgres
bash init.sh
```

Notes:
- Uses Bitnami PostgreSQL chart `16.7.21`
- Deployed to namespace `postgres`
- Persistence is disabled in `values.yaml` (data is not durable)
- Credentials in `values.yaml` are example/plaintext values; change them before any real usage

### WordPress

```bash
cd sample-apps/wordpress
bash init.sh
```

Notes:
- Uses Bitnami WordPress chart `25.0.5`
- Deployed to namespace `wordpress`
- Ingress is enabled and expects:
  - Ingress class `nginx`
  - A working cert-manager `ClusterIssuer` named `letsencrypt-prod`
  - DNS/external-dns setup for the configured hostname
- Persistence is disabled for both WordPress and MariaDB in `values.yaml`

## Outputs

- `cluster_name`
- `cluster_endpoint` (without `https://`)

Show outputs:

```bash
terraform output
```

## Destroy

```bash
terraform destroy -var="region=ap-southeast-1"
```

If you deployed sample apps, uninstall them first to speed up cleanup:

```bash
helm uninstall postgres -n postgres
helm uninstall wordpress -n wordpress
```

## Learning-only warning

This setup is intentionally minimal for learning and experimentation.

- It is not production hardened.
- Sample chart values include insecure defaults and no persistent storage.
- Review and secure IAM, networking, secrets, storage, and ingress settings before any real workload.