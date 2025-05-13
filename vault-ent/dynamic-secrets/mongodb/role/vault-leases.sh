#!/bin/sh

#set -xe

export VAULT_NAMESPACE=dev
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

# Check if jq exists, else download it
if [ ! -f "/tmp/jq" ]; then
   wget -O /tmp/jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
   chmod +x /tmp/jq
fi
alias jq="/tmp/jq"

# Run Vault lease lookup using jq
vault list --format=json sys/leases/lookup/mongodb/creds/dev-mongodb | jq -r '.[]' | xargs -I {} vault write -f sys/leases/lookup lease_id="mongodb/creds/dev-mongodb/{}"