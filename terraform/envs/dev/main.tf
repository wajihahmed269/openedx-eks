data "aws_caller_identity" "current" {}

locals {
  name           = "${var.project_name}-${var.environment}"
  s3_bucket_name = lower("${var.project_name}-${var.environment}-openedx-assets-${data.aws_caller_identity.current.account_id}-${var.aws_region}")

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  name               = local.name
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = local.common_tags
}

module "rds_security_group" {
  source = "../../modules/security-group"

  name        = "rds-mysql"
  name_prefix = local.name
  description = "RDS MySQL access for ${local.name}"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    mysql_from_eks_cluster_sg = {
      description              = "Allow MySQL from EKS cluster security group"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.eks.cluster_security_group_id
    }
  }

  egress_rules = {}

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name                       = "mysql"
  name_prefix                = local.name
  private_subnet_ids         = module.vpc.private_subnet_ids
  vpc_id                     = module.vpc.vpc_id
  rds_security_group_id      = module.rds_security_group.security_group_id
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  tags                       = local.common_tags
}

module "s3_openedx_assets" {
  source = "../../modules/s3"

  name              = "openedx-assets"
  name_prefix       = local.name
  bucket_name       = local.s3_bucket_name
  purpose           = "Open edX media/static/uploads"
  enable_versioning = var.s3_enable_versioning
  tags              = local.common_tags
}
