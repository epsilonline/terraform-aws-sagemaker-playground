######################################
# Create new VPC (conditional)
######################################

module "vpc" {
  count   = var.use_existing_vpc ? 0 : 1
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = local.vpc_name
  cidr = var.cidr_block
  azs  = length(var.azs) > 0 ? [var.azs[0]] : [data.aws_availability_zones.available.names[0]]

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  private_subnets = [var.private_subnet_cidrs[0]]
  public_subnets  = [var.public_subnet_cidrs[0]]

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_ngw_per_az
  enable_vpn_gateway     = var.enable_vpn_gateway

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

######################################
# Security Group for existing VPC
######################################

resource "aws_security_group" "sagemaker_existing_vpc" {
  count       = var.use_existing_vpc && var.existing_security_group_id == "" ? 1 : 0
  name        = "${var.domain_name}-${var.environment}-sagemaker-sg"
  description = "Security group for SageMaker domain in existing VPC"
  vpc_id      = var.existing_vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.domain_name}-${var.environment}-sagemaker-sg"
    }
  )
}

######################################
# Security Group Rules
######################################

resource "aws_security_group_rule" "allow_outbound_traffic" {
  count             = var.create_security_group_rules ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.security_group_id
}

resource "aws_security_group_rule" "allow_jupyter_inbound_traffic" {
  count             = var.create_security_group_rules ? 1 : 0
  type              = "ingress"
  from_port         = 8192
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [local.vpc_cidr]
  security_group_id = local.security_group_id
}

resource "aws_security_group_rule" "allow_git_inbound_traffic" {
  count             = var.create_security_group_rules ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.vpc_cidr]
  security_group_id = local.security_group_id
}

