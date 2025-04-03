#!/bin/sh
set -xe

export VAULT_NAMESPACE=dev
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

echo "Enabling GCP secrets engine demo"
echo "==========================="
echo "Working directory: $(pwd)"
echo "==========================="

vault write auth/demo-auth-mount/role/gcp-role \
		bound_service_account_names=gcp-sa \
		bound_service_account_namespaces=gcp \
		policies=gcp-policy \
		token_period=1h
sleep 10

vault secrets enable gcp || true
sleep 10

vault write gcp/config \
  credentials=@/tmp/gcp-credentials.json \
  ttl=300 \
  max_ttl=300
sleep 30

vault write gcp/static-account/$PROJECT_ID-viewer-key \
    service_account_email="vault-gcp-static-keys@$PROJECT_ID.iam.gserviceaccount.com" \
    secret_type="service_account_key" \
    bindings=-<<EOF
resource "//cloudresourcemanager.googleapis.com/projects/$PROJECT_ID" {
  roles = ["roles/viewer"]
}
EOF

vault write gcp/static-account/$PROJECT_ID-viewer-token \
    service_account_email="vault-gcp-static-tokens@$PROJECT_ID.iam.gserviceaccount.com" \
    secret_type="access_token" \
    token_scopes="https://www.googleapis.com/auth/cloud-platform" \
    bindings=-<<EOF
resource "//cloudresourcemanager.googleapis.com/projects/$PROJECT_ID" {
  roles = ["roles/viewer"]
}
EOF

vault policy write gcp-policy -<<EOF
path "/gcp/static-account/${PROJECT_ID}-viewer-token/token" {
   capabilities = ["read"]
}

path "/gcp/static-account/${PROJECT_ID}-viewer-key/key" {
   capabilities = ["read"]
}
EOF