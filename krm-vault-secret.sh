#!/bin/sh

# read the `kind: ResourceList` from stdin
resourceList=$(cat)

# extract secret resource name and data entries.
resourceName=$(echo "$resourceList" | yq e '.functionConfig.metadata.name' - )
data_count=$(echo "$resourceList" | yq e '.functionConfig.spec | length' - )

if [ "$data_count" -eq '0' ] || [ -z "$VAULT_ADDR" ] || [ -z "$VAULT_TOKEN" ]; then exit 1; fi

# output template
echo "
kind: ResourceList
items:
- kind: Secret
  apiVersion: v1
  metadata:
    name: $resourceName
  type: Opaque
  data:
"

# output data entry
for i in $(seq 0 $(("$data_count" - 1))); do
    data_name=$(echo "$resourceList" | yq e ".functionConfig.spec.[${i}].name" - )
    key=$(echo "$resourceList" | yq e ".functionConfig.spec.[${i}].key" - )
    field=$(echo "$resourceList" | yq e ".functionConfig.spec.[${i}].field" - )
    echo "    $data_name: $(vault kv get -field="${field}" "$key" | base64 -)"
done
