resource "aws_iam_role" "azure_stack_hci_role" {
  name = "azure_stack_hci_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "S3 access policy for EC2"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:*"],
        Resource = ["arn:aws:s3:::azure-stack-hci-iso-bucket/*"],
        Effect   = "Allow",
      },
    ],
  })
}

resource "aws_iam_policy" "azure_stack_hci_policy" {
  name        = "azure_stack_hci_policy"
  description = "Azure Stack HCI Policy for EC2"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:CreateVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:CreateVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:ModifySubnetAttribute"
        ],
        "Resource": "*"
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.azure_stack_hci_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}


resource "aws_iam_role_policy_attachment" "s3_access_policy_attach" {
  role       = aws_iam_role.azure_stack_hci_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "azure_hci_policy_attach" {
  role       = aws_iam_role.azure_stack_hci_role.name
  policy_arn = aws_iam_policy.azure_stack_hci_policy.arn
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "azure_stack_hci_profile"
  role = aws_iam_role.azure_stack_hci_role.name
}
