#!/bin/sh

#set -xe

export VAULT_NAMESPACE=us-west-org
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

# Check if jq exists, else download it
if [ ! -f "/tmp/jq" ]; then
   wget -O /tmp/jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
   chmod +x /tmp/jq
fi
alias jq="/tmp/jq"

# Run Vault lease lookup using jq
vault list -format=json "/sys/leases/lookup/gcp/roleset/$PROJECT_ID-viewer-key/key" | jq -r '.[]' | xargs -I {} vault lease lookup "gcp/roleset/$PROJECT_ID-viewer-key/key/{}"