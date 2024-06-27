# This script runs on VM startup
Write-Host "Running startup script"

# Add your custom startup commands here, e.g., installing software, configuring services, etc.
# Install Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList '/i AzureCLI.msi /quiet' -Wait

# Install Terraform
$TerraformVersion = "1.8.5"
Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_$TerraformVersion_windows_amd64.zip" -OutFile "terraform.zip"
Expand-Archive -Path "terraform.zip" -DestinationPath "C:\terraform"
$env:Path += ";C:\terraform"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::Machine)

# Install other necessary tools, e.g., PowerShell modules for Azure Arc
Install-Module -Name Az -AllowClobber -Force
Install-Module -Name Az.ConnectedKubernetes -AllowClobber -Force
