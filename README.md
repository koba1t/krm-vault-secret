# krm-vault-secret
Generate k8s secret Resource from [vault](https://github.com/hashicorp/vault) entry using kustomize [Exec KRM functions](https://kubectl.docs.kubernetes.io/guides/extending_kustomize/exec_krm_functions/).

This plugin can insert credentials dynamically when `kustomize build`.


## Requirement
Please install [yq(go-yq)](https://github.com/mikefarah/yq) and [vault](https://www.vaultproject.io/downloads).

## Example

```
# setup vault env var
export VAULT_ADDR='http://0.0.0.0:1234'
export VAULT_TOKEN=myroot

# write secrets to vault
# https://www.vaultproject.io/docs/commands/kv/put
vault kv put secret/pass passcode=my-long-passcode
vault kv put secret/addr email=my@www.example.com

# you can get secret from vault
# https://www.vaultproject.io/docs/commands/kv/get
vault kv get -field=passcode secret/pass
vault kv get -field=email secret/addr

$ kustomize build --enable-alpha-plugins --enable-exec example/
```
