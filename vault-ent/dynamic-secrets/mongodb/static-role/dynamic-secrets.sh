#!/bin/sh
set -xe
export VAULT_NAMESPACE=dev

#vault secrets enable -path=mongodb database

vault write mongodb/config/mongodb-database-static \
   plugin_name=mongodb-database-plugin \
   allowed_roles="dev-mongodb-static" \
   connection_url="mongodb://{{username}}:{{password}}@mongodb.mongodb.svc.cluster.local:27017,mongodb2.mongodb2.svc.cluster.local:27017/admin?authSource=admin" \
   username="root" \
   password="example"

vault write mongodb/static-roles/dev-mongodb-static \
   db_name=mongodb-database-static \
   username="vault" \
   rotation_period="87600h"

vault read mongodb/static-creds/dev-mongodb-static

vault policy write mongodb-static-auth-policy - <<EOF
path "mongodb/static-creds/dev-mongodb-static" {
   capabilities = ["read"]
}
EOF

vault write auth/demo-auth-mount/role/auth-role-static \
   bound_service_account_names=static-app \
   bound_service_account_namespaces=static-ns \
   token_ttl=0 \
   token_period=120 \
   token_policies=mongodb-static-auth-policy \
   audience=vault