# ***************************************************************************************************************************************
# *  main                                                                                                                               *
#  **************************************************************************************************************************************
#  *                                                                                                                                    *
#  * @License Starts                                                                                                                    *
#  *                                                                                                                                    *
#  * Copyright © 2023. MongoExpUser.  All Rights Reserved.                                                                              *
#  *                                                                                                                                    *
#  * License: MIT - https://github.com/MongoExpUser/Global-DB-Aurora-Postgres-Sless-V2-With-DR-and-ML-Capabilities/blob/main/LICENSE    *
#  *                                                                                                                                    *
#  * @License Ends                                                                                                                      *
#  **************************************************************************************************************************************
# *                                                                                                                                     *
# *  Project:                                                                                                                           *
# *    Global Aurora Postgres Serverless V2 Database Cluster with In-Database Machine Learning and Disaster Recovery (DR) Capabilities. *
# *                                                                                                                                     *
# *  Purpose:                                                                                                                           *
# *     Implements the deployment (Terraform) of AWS Global Aurora PostgreSQL Serverless Cluster v2                                     *
# *     and related resources for the Integration of Aurora Machine Learning and Aurora PostgreSQL Serverless V2, with DR option.       *
# *                                                                                                                                     *
#  **************************************************************************************************************************************
# *  The following resources are created:                                                                                               *
# *                                                                                                                                     *
# *   1) AWS Secret Manager's Secret (username and password) for AWS Aurora PostgreSQL Serverless Cluster                               *
# *                                                                                                                                     *
# *   2) AWS VPC Security  Group                                                                                                        *
# *                                                                                                                                     *
# *   3) AWS DB Subnet Group                                                                                                            *
# *                                                                                                                                     *
# *   4) AWS RDS Cluster Parameter Group                                                                                                *
# *                                                                                                                                     *
# *   5) AWS RDS DB Parameter group                                                                                                     *
# *                                                                                                                                     *
# *   6) a. AWS IAM Role (RDS monitoring role) to provide access to Cloudwatch for RDS Enhanced Monitoring                              *
# *                                                                                                                                     *
# *      b. AWS IAM Role (RDS DB-Comprehend role) to provide access to AWS Comprehend ML features                                       *
# *                                                                                                                                     *
# *      c. AWS IAM Role (RDS DB-Sagemaker role) to provide access to AWS SageMaker ML features                                         *
# *                                                                                                                                     *
# *   7) a. AWS Aurora PostgreSQL Serverless v2 Global Cluster                                                                          *
# *                                                                                                                                     *
# *      b. AWS Aurora PostgreSQL Serverless v2 Primary and Secondary Clusters, and Related Writer & Reader Instances                   *
# *                                                                                                                                     *
# *   8) a. AWS RDS Cluster Role Associations (for Associating Cluster with AWS Comprehend on the Primary & Secondary Clusters          *
# *                                                                                                                                     *
# *      b. AWS RDS Cluster Role Associations (for Associating Cluster with AWS SageMaker on the Primary & Secondary Cluster            *
# *                                                                                                                                     *
# **************************************************************************************************************************************



# 0. provider(s),  backend and local variables

provider "aws" {
  access_key                            = var.aws_access_key
  secret_key                            = var.aws_secret_key
  alias                                 = "primary"
  region                                = var.primary_region
}

provider "aws" {
  access_key                            = var.aws_access_key
  secret_key                            = var.aws_secret_key
  alias                                 = "secondary"
  region                                = var.secondary_region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # backend: option 1
  backend "local" { }
  
  # or use s3 backend (option 2) below , if preferred.
  
  # backend: option 2
  /*
  backend "s3" {
    bucket  = "bucket-name"
    key     = "global-aurora-pgs-v2-sless-dr-ml.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
  */
}

locals {
  base_tags = {
    "environment"                               = var.environment
    "region"                                    = var.region
    "project"                                   = var.project_name
    "creator"                                   = var.creator
    "map-migrated"                              = var.map_migrated
    "service-provider"                          = var.service_provider
  }
}


# 1. create credentials
# a. identity data
data "aws_caller_identity" "created" {}

# b. create password to be used as database password
resource "random_password" "created" {
  length                                =  var.random_password_length
  special                               =  var.random_password_true
  lower                                 =  var.random_password_true
  upper                                 =  var.random_password_true
  numeric                               =  var.random_password_true
  override_special                      =  var.random_password_override_special
}

# c. create uuid, to be appended  sg, subnet, parameter group, and monitoring role names, (uuid 3-element substring), to ensure uniqueness
resource "random_uuid" "created" { }

# d.create secret manager's secret - for storing credential
resource "aws_secretsmanager_secret" "created" {
  depends_on                            = [random_password.created, random_uuid.created]
  name                                  = "${var.org_name}-${var.environment}-${var.aws_secretsmanager_secret_name}-${substr(random_uuid.created.result, 0, 3)}"
  description                           = var.secret_description
  recovery_window_in_days               = var.recovery_window_in_days

  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.aws_secretsmanager_secret_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# e. create local variables for referencing purpose
locals {
  depends_on                            = [aws_secretsmanager_secret.created]
  account_id                            = data.aws_caller_identity.created.account_id
  unique_id                             = substr(random_uuid.created.result, 0, 3)
  credentials = {
    username                            = var.username
    password                            = random_password.created.result
  }
}

# f. create secret version - stores the credential (username and password) in secret manager's secret
resource "aws_secretsmanager_secret_version" "created" {
  depends_on                            = [aws_secretsmanager_secret.created]
  secret_id                             = aws_secretsmanager_secret.created.id
  secret_string                         = jsonencode(local.credentials)
}


# 2a. create security group for db access (primary cluster)
resource "aws_security_group" "created_primary" {
  depends_on                            = [aws_secretsmanager_secret_version.created]
  provider                              = aws.primary
  name                                  = "${var.org_name}-${var.environment}-${var.security_group_name}-${local.unique_id}"
  description                           = var.security_group_description
  vpc_id                                = var.vpc_id_primary

  ingress {
    description                         = var.ingress_ssh_description
    from_port                           = var.ingress_ssh_port
    to_port                             = var.ingress_ssh_port
    protocol                            = var.ingress_protocol
    cidr_blocks                         = var.ingress_cidr_blocks_primary
  }
  
 ingress {
    description                         = var.ingress_db_description
    from_port                           = var.ingress_db_port
    to_port                             = var.ingress_db_port
    protocol                            = var.ingress_protocol
    cidr_blocks                         = var.ingress_cidr_blocks_primary
  }
  
  egress {
    from_port                           = var.egress_port
    to_port                             = var.egress_port
    protocol                            = var.egress_protocol
    cidr_blocks                         = var.egress_cidr_blocks
  }
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.security_group_name}-${substr(random_uuid.created.result, 0, 3)}"
        Name                            = "${var.org_name}-${var.environment}-${var.security_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# 2b. create security group for db access (secondary cluster)
resource "aws_security_group" "created_secondary" {
  provider                              = aws.secondary
  depends_on                            = [aws_secretsmanager_secret_version.created]
  name                                  = "${var.org_name}-${var.environment}-${var.security_group_name}-${local.unique_id}"
  description                           = var.security_group_description
  vpc_id                                = var.vpc_id_secondary

  ingress {
    description                         = var.ingress_ssh_description
    from_port                           = var.ingress_ssh_port
    to_port                             = var.ingress_ssh_port
    protocol                            = var.ingress_protocol
    cidr_blocks                         = var.ingress_cidr_blocks_secondary
  }
  
 ingress {
    description                         = var.ingress_db_description
    from_port                           = var.ingress_db_port
    to_port                             = var.ingress_db_port
    protocol                            = var.ingress_protocol
    cidr_blocks                         = var.ingress_cidr_blocks_secondary
  }
  
  egress {
    from_port                           = var.egress_port
    to_port                             = var.egress_port
    protocol                            = var.egress_protocol
    cidr_blocks                         = var.egress_cidr_blocks
  }
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.security_group_name}-${substr(random_uuid.created.result, 0, 3)}"
        Name                            = "${var.org_name}-${var.environment}-${var.security_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}


# 3a. create a db subnet group (primary cluster)
resource "aws_db_subnet_group" "created_primary" {
  depends_on                            = [aws_security_group.created_primary]
  provider                              = aws.primary
  name                                  = "${var.org_name}-${var.environment}-${var.db_subnet_group_name}-${substr(random_uuid.created.result, 0, 3)}"
  description                           = var.db_subnet_group_description
  subnet_ids                            = var.db_subnet_ids_primary

  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.db_subnet_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# 3b. create a db subnet group (secondary cluster)
resource "aws_db_subnet_group" "created_secondary" {
  depends_on                            = [aws_security_group.created_secondary]
  provider                              = aws.secondary
  name                                  = "${var.org_name}-${var.environment}-${var.db_subnet_group_name}-${substr(random_uuid.created.result, 0, 3)}"
  description                           = var.db_subnet_group_description
  subnet_ids                            = var.db_subnet_ids_secondary

  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.db_subnet_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# 4a. create a cluster parameter group (primary cluster)
resource "aws_rds_cluster_parameter_group" "created_primary" {
  depends_on                            = [aws_db_subnet_group.created_primary]
   provider                              = aws.primary
  name                                  = "${var.org_name}-${var.environment}-${var.cluster_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
  family                                = var.cluster_parameter_group_family
  description                           = var.cluster_parameter_group_description
  
  parameter {
    name                                = "timezone"
    value                               = var.cluster_timezone
    apply_method                        = var.cluster_apply_method
  }
  
  parameter {
    name                                = "orafce.timezone"
    value                               = var.cluster_orafce_timezone
    apply_method                        = var.cluster_apply_method
  }

  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.cluster_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# 4b. create a cluster parameter group (secondary cluster)
resource "aws_rds_cluster_parameter_group" "created_secondary" {
  depends_on                            = [aws_db_subnet_group.created_secondary]
  provider                              = aws.secondary
  name                                  = "${var.org_name}-${var.environment}-${var.cluster_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
  family                                = var.cluster_parameter_group_family
  description                           = var.cluster_parameter_group_description
  
  parameter {
    name                                = "timezone"
    value                               = var.cluster_timezone
    apply_method                        = var.cluster_apply_method
  }
  
  parameter {
    name                                = "orafce.timezone"
    value                               = var.cluster_orafce_timezone
    apply_method                        = var.cluster_apply_method
  }

  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.cluster_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# 5a. create a db/instance parameter group
resource "aws_db_parameter_group" "created_primary" {
  depends_on                            = [aws_rds_cluster_parameter_group.created_primary]
  provider                              = aws.primary
  name                                  = "${var.org_name}-${var.environment}-${var.db_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
  family                                = var.db_parameter_group_family
  description                           = var.db_parameter_group_description
  
  parameter {
    name                                = "shared_preload_libraries"
    value                               = var.db_shared_preload_libraries
    apply_method                        = var.db_apply_method
  }
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.db_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# 5b. create a db/instance parameter group
resource "aws_db_parameter_group" "created_secondary" {
  depends_on                            = [aws_rds_cluster_parameter_group.created_secondary]
  provider                              = aws.secondary
  name                                  = "${var.org_name}-${var.environment}-${var.db_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
  family                                = var.db_parameter_group_family
  description                           = var.db_parameter_group_description
  
  parameter {
    name                                = "shared_preload_libraries"
    value                               = var.db_shared_preload_libraries
    apply_method                        = var.db_apply_method
  }
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.db_parameter_group_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
  
}

# 6a. create I AM role for enabling "enhanced monitoring" - provides access to Cloudwatch for RDS Enhanced Monitoring
resource "aws_iam_role" "created_monitoring" {
  depends_on                            = [aws_secretsmanager_secret_version.created]
  name                                  = "${var.org_name}-${var.environment}-${var.rds_monitoring_role_name}-${substr(random_uuid.created.result, 0, 3)}"
  path                                  = "/"
  managed_policy_arns                   = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  assume_role_policy                    = jsonencode({
    Version                             = "2012-10-17"
    Statement                           = [
      {
        Action                          = "sts:AssumeRole"
        Effect                          = "Allow"
        Sid                             = "AllowRDSMonitoringToAssumeRole"
        Principal                       = {
          Service                       = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.rds_monitoring_role_name}-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}

# 6b. create I AM role for providing access to comprehend ml service (primary cluster)
resource "aws_iam_role" "created_comprehend_primary" {
  depends_on                            = [aws_secretsmanager_secret_version.created]
  name                                  = "${var.org_name}-${var.environment}-${var.aurora_comprehend_role_name}-primary-${substr(random_uuid.created.result, 0, 3)}"
  path                                  = "/"
  managed_policy_arns                   = ["arn:aws:iam::aws:policy/ComprehendFullAccess"]
  assume_role_policy                    = jsonencode({
    Version                             = "2012-10-17"
    Statement                           = [
      {
        Action                          = "sts:AssumeRole"
        Effect                          = "Allow"
        Sid                             = "AllowRDSAccessToAssumeRoleComprehend"
        Principal                       = {
          Service                       = "rds.amazonaws.com"
        }
      },
    ]
  })
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.aurora_comprehend_role_name}-primary-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}

# 6c. create I AM role for providing access to sagemaker ml service (primary cluster)
resource "aws_iam_role" "created_sagemaker_primary" {
  depends_on                            = [aws_secretsmanager_secret_version.created]
  name                                  = "${var.org_name}-${var.environment}-${var.aurora_sagemaker_role_name}-primary-${substr(random_uuid.created.result, 0, 3)}"
  path                                  = "/"
  managed_policy_arns                   = ["arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"]
  assume_role_policy                    = jsonencode({
    Version                             = "2012-10-17"
    Statement                           = [
      {
        Action                          = "sts:AssumeRole"
        Effect                          = "Allow"
        Sid                             = "AllowRDSAccessToAssumeRoleSagemaker"
        Principal                       = {
          Service                       = "rds.amazonaws.com"
        }
      },
    ]
  })
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.aurora_sagemaker_role_name}-primary-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}

# 6d. create I AM role for providing access to comprehend ml service (secondary cluster)
resource "aws_iam_role" "created_comprehend_secondary" {
  depends_on                            = [aws_secretsmanager_secret_version.created]
  name                                  = "${var.org_name}-${var.environment}-${var.aurora_comprehend_role_name}-secondary-${substr(random_uuid.created.result, 0, 3)}"
  path                                  = "/"
  managed_policy_arns                   = ["arn:aws:iam::aws:policy/ComprehendFullAccess"]
  assume_role_policy                    = jsonencode({
    Version                             = "2012-10-17"
    Statement                           = [
      {
        Action                          = "sts:AssumeRole"
        Effect                          = "Allow"
        Sid                             = "AllowRDSAccessToAssumeRoleComprehend"
        Principal                       = {
          Service                       = "rds.amazonaws.com"
        }
      },
    ]
  })
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.aurora_comprehend_role_name}-secondary-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}

# 6e. create I AM role for providing access to sagemaker ml service (primary cluster)
resource "aws_iam_role" "created_sagemaker_secondary" {
  depends_on                            = [aws_secretsmanager_secret_version.created]
  name                                  = "${var.org_name}-${var.environment}-${var.aurora_sagemaker_role_name}-secondary-${substr(random_uuid.created.result, 0, 3)}"
  path                                  = "/"
  managed_policy_arns                   = ["arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"]
  assume_role_policy                    = jsonencode({
    Version                             = "2012-10-17"
    Statement                           = [
      {
        Action                          = "sts:AssumeRole"
        Effect                          = "Allow"
        Sid                             = "AllowRDSAccessToAssumeRoleSagemaker"
        Principal                       = {
          Service                       = "rds.amazonaws.com"
        }
      },
    ]
  })
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.aurora_sagemaker_role_name}-secondary-${substr(random_uuid.created.result, 0, 3)}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}


# 7a. create global Cluster
resource "aws_rds_global_cluster" "created" {
  depends_on                            =  [aws_iam_role.created_monitoring,
                                            aws_iam_role.created_comprehend_primary,
                                            aws_iam_role.created_sagemaker_primary,
                                            aws_iam_role.created_comprehend_secondary,
                                            aws_iam_role.created_sagemaker_secondary
                                          ]
  global_cluster_identifier             =  "${var.org_name}-${var.environment}-${var.global_cluster_identifier}"
  engine                                =  var.engine
  engine_version                        =  var.engine_version
  deletion_protection                   =  var.deletion_protection
  storage_encrypted                     =  var.storage_encrypted
}

# 7b. create aurora postgress serverless cluster (primary)
resource "aws_rds_cluster" "created_primary" {
  depends_on                            =   [aws_rds_global_cluster.created]
  provider                              =   aws.primary
  #count                                =   var.primary_count
  global_cluster_identifier             =   aws_rds_global_cluster.created.id
  cluster_identifier                    =   "${var.org_name}-${var.environment}-${var.cluster_identifier_primary}"
  engine                                =   var.engine
  engine_mode                           =   var.engine_mode
  engine_version                        =   var.engine_version
  master_username                       =   local.credentials.username
  master_password                       =   local.credentials.password
  
  backup_retention_period               =   var.backup_retention_period
  preferred_backup_window               =   var.preferred_backup_window
  preferred_maintenance_window          =   var.preferred_maintenance_window
  
  enabled_cloudwatch_logs_exports       =   var.enabled_cloudwatch_logs_exports
  db_cluster_parameter_group_name       =   aws_rds_cluster_parameter_group.created_primary.name
  db_subnet_group_name                  =   aws_db_subnet_group.created_primary.name
  vpc_security_group_ids                =   [aws_security_group.created_primary.id]
  allow_major_version_upgrade           =   var.allow_major_version_upgrade
  apply_immediately                     =   var.apply_immediately
  storage_encrypted                     =   var.storage_encrypted
  copy_tags_to_snapshot                 =   var.copy_tags_to_snapshot
  deletion_protection                   =   var.deletion_protection
  skip_final_snapshot                   =   var.skip_final_snapshot
  final_snapshot_identifier             =   "${var.org_name}-${var.environment}-${var.cluster_identifier_primary}-snapshot"
  #availability_zones                   =   var.#availability_zones
  
  serverlessv2_scaling_configuration {
    max_capacity                        =   var.max_capacity
    min_capacity                        =   var.min_capacity
  }
  
  tags = merge(
    {
        name                            =   "${var.org_name}-${var.environment}-${var.cluster_identifier_primary}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}

# 7c. create aurora postgress serverless db instance(s) on the primary cluster
resource "aws_rds_cluster_instance" "created_primary_instance" {
  depends_on                            =  [aws_rds_cluster.created_primary]
  provider                              =  aws.primary
  count                                 =  length(var.cluster_instance_identifiers_primary)
  identifier                            =  "${var.cluster_instance_identifiers_primary[count.index]}"
  cluster_identifier                    =  aws_rds_cluster.created_primary.id
  instance_class                        =  var.instance_class
  engine                                =  aws_rds_cluster.created_primary.engine
  engine_version                        =  aws_rds_cluster.created_primary.engine_version
  publicly_accessible                   =  var.publicly_accessible
  preferred_maintenance_window          =  var.preferred_maintenance_window
  db_parameter_group_name               =  aws_db_parameter_group.created_primary.name
  db_subnet_group_name                  =  aws_db_subnet_group.created_primary.name
  performance_insights_enabled          =  var.performance_insights_enabled
  monitoring_interval                   =  var.monitoring_interval
  monitoring_role_arn                   =  aws_iam_role.created_monitoring.arn
  auto_minor_version_upgrade            =  var.auto_minor_version_upgrade
  apply_immediately                     =  var.apply_immediately
  copy_tags_to_snapshot                 =  var.copy_tags_to_snapshot
  
  tags = merge(
    {
        name                            = "${var.cluster_instance_identifiers_primary[count.index]}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}


#  create sleep time: sleep to allow creation and initiation of primary cluster and its instance(s) before creating secondary cluster
resource "time_sleep" "sleep_before_creating_secondary_cluster" {
  depends_on = [aws_rds_cluster_role_association.created_sagemaker_primary]
  create_duration = var.sleep_time
}

# 7d. create aurora postgress serverless cluster (secondary)
resource "aws_rds_cluster" "created_secondary" {
  depends_on                            =   [time_sleep.sleep_before_creating_secondary_cluster]
  provider                              =   aws.secondary
  #count                                =   var.secondary_count
  global_cluster_identifier             =   aws_rds_global_cluster.created.id
  cluster_identifier                    =   "${var.org_name}-${var.environment}-${var.cluster_identifier_secondary}"
  engine                                =   var.engine
  engine_mode                           =   var.engine_mode
  engine_version                        =   var.engine_version
  
  backup_retention_period               =   var.backup_retention_period
  preferred_backup_window               =   var.preferred_backup_window
  preferred_maintenance_window          =   var.preferred_maintenance_window
  
  enabled_cloudwatch_logs_exports       =   var.enabled_cloudwatch_logs_exports
  db_cluster_parameter_group_name       =   aws_rds_cluster_parameter_group.created_secondary.name
  db_subnet_group_name                  =   aws_db_subnet_group.created_secondary.name
  vpc_security_group_ids                =   [aws_security_group.created_secondary.id]
  allow_major_version_upgrade           =   var.allow_major_version_upgrade
  apply_immediately                     =   var.apply_immediately
  storage_encrypted                     =   var.storage_encrypted
  copy_tags_to_snapshot                 =   var.copy_tags_to_snapshot
  deletion_protection                   =   var.deletion_protection
  skip_final_snapshot                   =   var.skip_final_snapshot
  final_snapshot_identifier             =   "${var.org_name}-${var.environment}-${var.cluster_identifier_secondary}-snapshot"
  kms_key_id                            =   var.kms_key_id_arn_default_secondary_region
  #availability_zones                   =   var.#availability_zones
  
  serverlessv2_scaling_configuration {
    max_capacity                        =   var.max_capacity
    min_capacity                        =   var.min_capacity
  }
  
  tags = merge(
    {
        name                            = "${var.org_name}-${var.environment}-${var.cluster_identifier_secondary}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}


# 7e. create aurora postgress serverless db instance(s) on the secondary cluster
resource "aws_rds_cluster_instance" "created_secondary_instance" {
  depends_on                            =  [aws_rds_cluster.created_secondary]
  provider                              =  aws.secondary
  count                                 =  length(var.cluster_instance_identifiers_secondary)
  identifier                            =  "${var.cluster_instance_identifiers_secondary[count.index]}"
  cluster_identifier                    =  aws_rds_cluster.created_secondary.id
  instance_class                        =  var.instance_class
  engine                                =  aws_rds_cluster.created_secondary.engine
  engine_version                        =  aws_rds_cluster.created_secondary.engine_version
  publicly_accessible                   =  var.publicly_accessible
  preferred_maintenance_window          =  var.preferred_maintenance_window
  db_parameter_group_name               =  aws_db_parameter_group.created_secondary.name
  db_subnet_group_name                  =  aws_db_subnet_group.created_secondary.name
  performance_insights_enabled          =  var.performance_insights_enabled
  monitoring_interval                   =  var.monitoring_interval
  monitoring_role_arn                   =  aws_iam_role.created_monitoring.arn
  auto_minor_version_upgrade            =  var.auto_minor_version_upgrade
  apply_immediately                     =  var.apply_immediately
  copy_tags_to_snapshot                 =  var.copy_tags_to_snapshot
  
  tags = merge(
    {
        name                            = "${var.cluster_instance_identifiers_secondary[count.index]}"
    },
    {
        creator                         = var.creator
    },
    local.base_tags
  )
}


# 8a. create db cluster role association, that allows aurora cluster access to the comprehend service (primary cluster)
resource "aws_rds_cluster_role_association" "created_comprehend_primary" {
  depends_on                            = [aws_rds_cluster_instance.created_primary_instance]
  provider                              = aws.primary
  db_cluster_identifier                 = aws_rds_cluster.created_primary.id
  feature_name                          = var.comprehend_feature_name
  role_arn                              = aws_iam_role.created_comprehend_primary.arn
}

# 8b. create db clsuter role association, that allows aurora cluster access to the sagemaker service (primary cluster)
resource "aws_rds_cluster_role_association" "created_sagemaker_primary" {
  depends_on                            = [aws_rds_cluster_role_association.created_comprehend_primary]
  provider                              = aws.primary
  db_cluster_identifier                 = aws_rds_cluster.created_primary.id
  feature_name                          = var.sagemaker_feature_name
  role_arn                              = aws_iam_role.created_sagemaker_primary.arn
}

# 8c. create db cluster role association, that allows aurora cluster access to the comprehend service (secondary cluster)
resource "aws_rds_cluster_role_association" "created_comprehend_secondary" {
  depends_on                            = [aws_rds_cluster_instance.created_secondary_instance]
  provider                              =  aws.secondary
  db_cluster_identifier                 = aws_rds_cluster.created_secondary.id
  feature_name                          = var.comprehend_feature_name
  role_arn                              = aws_iam_role.created_comprehend_secondary.arn
}

# 8d. create db clsuter role association, that allows aurora cluster access to the sagemaker service service (secondary cluster)
resource "aws_rds_cluster_role_association" "created_sagemaker_secondary" {
  depends_on                            = [aws_rds_cluster_role_association.created_comprehend_secondary]
  provider                              = aws.secondary
  db_cluster_identifier                 = aws_rds_cluster.created_secondary.id
  feature_name                          = var.sagemaker_feature_name
  role_arn                              = aws_iam_role.created_sagemaker_secondary.arn
}
