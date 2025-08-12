helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

helm upgrade --install wordpress bitnami/wordpress --version 25.0.5 \
  --namespace wordpress --create-namespace \
  --values values.yaml