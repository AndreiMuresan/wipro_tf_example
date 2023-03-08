resource "aws_security_group" "ccf_ec2_instance_sg" {
  name          = "${var.application}-ccf-ec2-instance-sg"
  vpc_id        = var.vpc_id

  ingress {
    protocol    = -1
    self        = true
    from_port   = 0
    to_port     = 0
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags          = local.tags
}

resource "aws_iam_instance_profile" "ccf_ec2_instance_profile" {
  name          = "${var.application}-ccf-ec2-instance-profile"
  role          = aws_iam_role.ccf_cli_ec2_role.name
  tags          = local.tags
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ccf_ec2_instance_sg.id]
  subnet_id              = var.private_subnet_id
  user_data              = file("install.sh")
  iam_instance_profile   = aws_iam_instance_profile.ccf_ec2_instance_profile.name
  tags                   = local.tags
}
