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

`kind create cluster --config ../k8s/cluster-config.yaml`

# Enable Azure ARC Integration on the created cluster
```shell
az connectedk8s connect --name aks-demo001 --resource-group aks-demo001
```

# Delete Azure ARC Integration on the K8s Cluster
```shell
 az connectedk8s delete --name aks-demo001 --resource-group aks-demo001 --yes
```

# Create Extension for AzureKeyVault
```shell
CLUSTER_NAME="aks-demo001"
RESOURCE_GROUP="aks-demo001"
az k8s-extension create --name "akv-secrets-provider" \
                        --extension-type "Microsoft.AzureKeyVaultSecretsProvider" \
                        --cluster-name "${CLUSTER_NAME}" \
                        --resource-group "${RESOURCE_GROUP}" \
                        --cluster-type "connectedClusters" \
                        --scope "cluster" \
                        --release-train "stable" \
                        --configuration-settings "secrets-store-csi-driver.enableSecretRotation=true" \
                        "secrets-store-csi-driver.rotationPollInterval=1h"

```
# Create GitOps with Azure ARC
```shell
CLUSTER_NAME="aks-demo001"
RESOURCE_GROUP="aks-demo001"
az k8s-configuration flux create \
  --name nginx-app-gitops-demo \
  --cluster-name ${CLUSTER_NAME} \
  --resource-group ${RESOURCE_GROUP} \
  --scope cluster \
  --namespace cluster-config \
  --kind git \
  --cluster-type connectedClusters \
  --url https://github.com/soumentrivedi/azure-arc-poc \
  --branch main \
  --kustomization name=infra path=./gitops/infra prune=true \
  --kustomization name=apps path=./gitops/apps/staging prune=true dependsOn=\["infra"\]
```
# Update GitOps Configuration
```shell
CLUSTER_NAME="aks-demo001"
RESOURCE_GROUP="aks-demo001"
az k8s-configuration flux update \
  --name nginx-app-gitops-demo \
  --cluster-name ${CLUSTER_NAME} \
  --resource-group ${RESOURCE_GROUP} \
  --kind git \
  --cluster-type connectedClusters \
  --url https://github.com/soumentrivedi/azure-arc-poc \
  --branch main \
  --kustomization name=infra path=./gitops/infra prune=true \
  --kustomization name=apps path=./gitops/apps/staging prune=true dependsOn=\["infra"\]

```
# Delete GitOps Setup with Azure ARC
```shell
 az k8s-configuration flux delete --name nginx-app-gitops-demo \
    --resource-group  ${RESOURCE_GROUP} --cluster-name ${CLUSTER_NAME} \
    -t connectedClusters --yes
```

# Test AzureKeyVault
Requirements: `pip3 install azure-keyvault azure-identity`
Command: `python3 test/test-secrets.py`

# Secret Management Setup
```shell
#!/bin/bash
export AZ_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export RESOURCE_GROUP="aks-demo001"
export CLUSTER_NAME="aks-demo001"

export KV_NAME="aks-demo01-vault"
export KV_RESOURCE_GROUP="MyResourceGroup"
```
