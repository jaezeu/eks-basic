helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm upgrade --install postgres bitnami/postgresql --version 16.7.21 \
  --namespace postgres --create-namespace \
  --values values.yaml