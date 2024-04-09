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
  --kustomization name=apps path=./gitops/apps/staging prune=true dependsOn=\["infra"\] \
  --kustomization name=secret-app path=./gitops/secret-app prune=true dependsOn=\["infra"\]
```

# Test AzureKeyVault
Requirements: `pip3 install azure-keyvault azure-identity`
Command: `python3 test/test-secrets.py`
