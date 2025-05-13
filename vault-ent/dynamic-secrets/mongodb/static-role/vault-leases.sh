#!/bin/sh

#set -xe

export VAULT_NAMESPACE=dev
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

# Run Vault lease lookup
vault read mongodb/static-creds/dev-mongodb-static