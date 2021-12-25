#!/bin/sh

# read the `kind: ResourceList` from stdin
resourceList=$(cat)

# extract secret resource name and data entries.
resourceName=$(echo -E "$resourceList" | yq e '.functionConfig.metadata.name' - )
data_count=$(echo -E "$resourceList" | yq e '.functionConfig.spec | length' - )

if [ $data_count -eq '0' ] || [ -z $VAULT_ADDR ] || [ -z $VAULT_TOKEN ]; then exit 1; fi

# output template
echo -E "
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
for i in `seq 0 $(expr $data_count - 1)`; do
    data_name=$(echo -E "$resourceList" | yq e ".functionConfig.spec.[${i}].name" - )
    key=$(echo -E "$resourceList" | yq e ".functionConfig.spec.[${i}].key" - )
    field=$(echo -E "$resourceList" | yq e ".functionConfig.spec.[${i}].field" - )
    echo -E "    $data_name: $(vault kv get -field=$field $key | base64 -)"
done
