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
