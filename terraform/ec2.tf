locals {
  ami_id         = "ami-0d12b76c0a0e2ddbd" # 'ami-0d12b76c0a0e2ddbd' AMI ID for Windows Server 2016 Hyper-V in eu-west-2
  iso_name       = "AzureStackHCI_20349.1607_en-us.iso"
  s3_bucket_name = "azure-stack-hci-iso-bucket"
}
resource "aws_instance" "bare_metal_instance" {
  depends_on                  = [module.vpc, aws_security_group.allow_rdp, aws_security_group.ssm_vpc_endpoint]
  ami                         = local.ami_id
  instance_type               = "i3.metal"
  key_name                    = "azure-stack-hci-poc" # This key pair has been created manually for now
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_rdp.id, aws_security_group.ssm_vpc_endpoint.id]
  iam_instance_profile         = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              <powershell>
              Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
              while (!(Get-WindowsFeature -Name Hyper-V).InstallState -eq 'Installed') { Start-Sleep -s 5 }
              New-VMSwitch -Name "ExternalSwitch" -NetAdapterName "Ethernet" -AllowManagementOS $true
              New-Item -Path 'C:\iso' -ItemType Directory
              Read-S3Object -BucketName s3://azure-stack-hci-iso-bucket -Key 'AzureStackHCI_20349.1607_en-us.iso' -File 'C:\iso\AzureStackHCI_20349.1607_en-us.iso'
              Mount-DiskImage -ImagePath 'C:\iso\AzureStackHCI_20349.1607_en-us.iso'
              </powershell>
              EOF

  tags = merge(local.tags, {
    Name = format("bm-%s-%s", local.tags.used_for, module.vpc.public_subnets[0])
  })
}
