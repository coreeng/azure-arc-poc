
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.public_subnets

  security_group_ids = [aws_security_group.ssm_vpc_endpoint.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.public_subnets

  security_group_ids = [aws_security_group.ssm_vpc_endpoint.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.public_subnets

  security_group_ids = [aws_security_group.ssm_vpc_endpoint.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  depends_on = [module.vpc]
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = [module.vpc.default_route_table_id]

}
