resource "aws_security_group" "allow_rdp" {
  name        = "allow_rdp"
  description = "Allow RDP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "RDP access from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "allow_rdp"
  })
}


resource "aws_security_group" "ssm_vpc_endpoint" {
  name        = "ssm_vpc_endpoint_sg"
  description = "Security group for SSM VPC Endpoints"
  vpc_id      = module.vpc.vpc_id

  # Allow outbound HTTPS traffic to the SSM endpoints
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Adjust the ingress rules based on your needs
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSM VPC Endpoint SG"
  }
}
