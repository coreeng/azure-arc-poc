locals {
  ami_id         = "ami-0d12b76c0a0e2ddbd" # 'ami-0bfee1c85ef54e1fd' - Windows Server 2019 HyperV or 'ami-0d12b76c0a0e2ddbd' AMI ID for Windows Server 2016 Hyper-V in eu-west-2 or 'ami-0aaf71c5a997aec44' for Windows Server 2019 HyperV
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
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  root_block_device {
    volume_size = 500
  }
  metadata_options {
    http_tokens               = "required"
    http_put_response_hop_limit = 2
    http_endpoint             = "enabled"
    instance_metadata_tags = "enabled"
  }
  user_data = <<-EOF
              <powershell>
              # Ensure RDP and HTTPS remain accessible
              netsh advfirewall firewall add rule name="Open RDP Port 3389" dir=in action=allow protocol=TCP localport=3389
              netsh advfirewall firewall add rule name="Open HTTPS Port 443" dir=in action=allow protocol=TCP localport=443

              # Disable Windows Defender if it gets enabled
              schtasks /create /sc onstart /tn "DisableWindowsDefender" /tr "powershell -Command Set-MpPreference -DisableRealtimeMonitoring \$true"

              # Ensure SSM agent is installed and running
              Write-Host "Installing SSM Agent..."
              Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/EC2Install.ps1 -OutFile $env:USERPROFILE\EC2Install.ps1
              powershell.exe -ExecutionPolicy Unrestricted -File $env:USERPROFILE\EC2Install.ps1
              Start-Service AmazonSSMAgent

              # Ensure SSM agent starts on reboot
              Set-Service AmazonSSMAgent -StartupType Automatic
              schtasks /create /sc onstart /tn "StartSSMAgent" /tr "powershell -Command Start-Service AmazonSSMAgent"

              # Install AWS CLI for any SSM commands
              Invoke-WebRequest "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "C:\\Temp\\AWSCLIV2.msi"
              Start-Process msiexec.exe -ArgumentList '/i C:\\Temp\\AWSCLIV2.msi /qn' -NoNewWindow -Wait

              Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
              while (!(Get-WindowsFeature -Name Hyper-V).InstallState -eq 'Installed') { Start-Sleep -s 5 }
              New-Item -Path 'C:\iso' -ItemType Directory
              Read-S3Object -BucketName azure-stack-hci-iso-bucket -Key 'AzureStackHCI_20349.1607_en-us.iso' -File 'C:\iso\AzureStackHCI_20349.1607_en-us.iso'
              Mount-DiskImage -ImagePath 'C:\iso\AzureStackHCI_20349.1607_en-us.iso'
              </powershell>
              EOF

  tags = merge(local.tags, {
    Name = format("bm-%s-%s", local.tags.used_for, module.vpc.public_subnets[0])
  })
}
