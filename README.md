# Create kind cluster
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: aks-demo001
nodes:
- role: control-plane
- role: worker
- role: worker
```

`kubectl apply -f <yaml-file-above>.yaml`

# Create GitOps with Azure Arc
```shell
az k8s-configuration flux create \
  --name nginx-app-gitops-demo \
  --cluster-name aks-demo001 \
  --resource-group aks-demo001 \
  --scope cluster \
  --namespace default \
  --kind git \
  --cluster-type connectedClusters \
  --url https://github.com/soumentrivedi/azure-arc-poc \
  --branch main
```

# Test AzureKeyVault
```python
import os
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

keyVaultName = "aks-demo01-vault"
KVUri = f"https://aks-demo01-vault.vault.azure.net"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KVUri, credential=credential)

secretName = "test-key"
secretValue = "test-secret-value"

print(f"Creating a secret in aks-demo01-vault called '{secretName}' with the value '{secretValue}' ...")

client.set_secret(secretName, secretValue)

print(" done.")

print(f"Retrieving your secret from aks-demo01-vault.")

retrieved_secret = client.get_secret(secretName)

print(f"Your secret is '{retrieved_secret.value}'.")
print(f"Deleting your secret from aks-demo01-vault ...")

poller = client.begin_delete_secret(secretName)
deleted_secret = poller.result()

print(" done.")

```

Requirements: `pip3 install azure-keyvault azure-identity`
Command: `python3 secret.py`
