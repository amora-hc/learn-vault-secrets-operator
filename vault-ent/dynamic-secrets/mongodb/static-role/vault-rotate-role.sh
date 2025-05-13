#!/bin/sh

#set -xe

export VAULT_NAMESPACE=dev
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

# Rotate role credentials and run Vault lease lookup
vault write -f mongodb/rotate-role/dev-mongodb-static
vault read mongodb/static-creds/dev-mongodb-static