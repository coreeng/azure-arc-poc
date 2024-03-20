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
Requirements: `pip3 install azure-keyvault azure-identity`
Command: `python3 test/test-secrets.py`
