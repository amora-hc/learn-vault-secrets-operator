#!/bin/sh
set -xe
export VAULT_NAMESPACE=dev

vault secrets enable -path=mongodb database

vault write mongodb/config/mongodb-database \
   plugin_name=mongodb-database-plugin \
   allowed_roles="dev-mongodb" \
   connection_url="mongodb://{{username}}:{{password}}@mongodb.mongodb.svc.cluster.local:27017" \
   username="root" \
   password="example"

vault write mongodb/roles/dev-mongodb \
    db_name=mongodb-database \
    creation_statements='{ "db": "admin", "roles": [{ "role": "readWrite" }] }' \
    default_ttl="1h" \
    max_ttl="24h"

vault read mongodb/creds/dev-mongodb

vault policy write mongodb-auth-policy - <<EOF
path "mongodb/creds/dev-mongodb" {
   capabilities = ["read"]
}
EOF

vault write auth/demo-auth-mount/role/auth-role \
   bound_service_account_names=mongo-app \
   bound_service_account_namespaces=mongo-ns \
   token_ttl=0 \
   token_period=120 \
   token_policies=mongodb-auth-policy \
   audience=vault