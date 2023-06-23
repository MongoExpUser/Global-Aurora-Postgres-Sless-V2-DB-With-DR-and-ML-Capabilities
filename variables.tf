#  **************************************************************************************************************************************
#  *  variables.tf                                                                                                                      *
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


# 0. organization identifier, project, creator environmental, region, tagging and provider variables
variable "org_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "creator" {
  type = string
}

variable "map_migrated" {
  type = string
}

variable "service_provider" {
  type = string
}

# provider variables
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {}

variable "primary_region" {
  type = string
}

variable "secondary_region" {
  type = string
}


# 1. credentials-related  variables
variable "random_password_length" {
  type = number
}

variable "random_password_true" {
  type = bool
}

variable "random_password_override_special" {
  type  = string
  description = "A customized list of random special characters to be included in the password. The list overides the default special characters."
}

variable "recovery_window_in_days" {
  type = number
}

variable "secret_description" {
  type = string
}

variable "aws_secretsmanager_secret_name" {
  type = string
}



# 2. security group variables
variable "security_group_name" {
  type = string
}

variable "security_group_description" {
  type = string
}

variable "vpc_id_primary" {
  type = string
}

variable "vpc_id_secondary" {
  type = string
}

variable "ingress_ssh_description" {
  type = string
}

variable "ingress_ssh_port" {
  type = number
}

variable "ingress_protocol" {
  type = string
}

variable "ingress_cidr_blocks_primary" {
  type = list(string)
}

variable "ingress_cidr_blocks_secondary" {
  type = list(string)
}

variable "ingress_db_description" {
  type = string
}

variable "ingress_db_port" {
  type = number
}

variable "egress_port" {
  type = number
}

variable "egress_protocol" {
  type = string
}

variable "egress_cidr_blocks" {
  type = list(string)
}


# 3. db subnet group variables
variable "db_subnet_group_description" {
  type = string
}

variable "db_subnet_group_name"{
  type = string
}

variable "db_subnet_ids_primary" {
  type = list(string)
}

variable "db_subnet_ids_secondary" {
  type = list(string)
}


# 4. cluster parameter group variables
variable "cluster_parameter_group_name" {
  type = string
}

variable "cluster_parameter_group_family" {
  type = string
}

variable "cluster_parameter_group_description" {
  type = string
}

variable "cluster_orafce_timezone" {
  type = string
}

variable "cluster_timezone" {
  type = string
}

variable "cluster_apply_method" {
  type = string
}


# 5. db/instance parameter group variables
variable "db_parameter_group_name" {
  type = string
}

variable "db_parameter_group_family" {
  type = string
}

variable "db_parameter_group_description" {
  type = string
}

variable "db_shared_preload_libraries" {
  type = string
}


variable "db_apply_method" {
  type = string
}


# 6 . I am role variable(s)
variable "rds_monitoring_role_name" {
  type = string
}

variable "aurora_comprehend_role_name" {
  type = string
}

variable "aurora_sagemaker_role_name" {
  type = string
}

# 7. aurora postgresql serverless cluster and cluster instance variables
variable "sleep_time" {
  type = string
}

variable "global_cluster_identifier" {
  type = string
}

variable "cluster_identifier_primary" {
  type = string
}

variable "cluster_identifier_secondary" {
  type = string
}

variable "cluster_instance_identifiers_primary" {
  type = list(string)
}

variable "cluster_instance_identifiers_secondary" {
  type = list(string)
}

/*
variable "primary_count" {
  type = number
}

variable "secondary_count" {
  type = number
}
*/

variable "instance_class" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_mode" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "username" {
  type = string
}

variable "backup_retention_period" {
  type = number
}

variable "preferred_backup_window" {
  type = string
}

variable "preferred_maintenance_window" {
  type = string
}

variable "storage_encrypted" {
  type  = bool
}


variable "publicly_accessible" {
  type  = bool
}

variable "enabled_cloudwatch_logs_exports" {
  type  = list(string)
}

variable "performance_insights_enabled" {
  type  = bool
}

variable "monitoring_interval" {
  type  = number
}

variable "allow_major_version_upgrade" {
  type = bool
}

variable "auto_minor_version_upgrade" {
  type = bool
}

variable "apply_immediately" {
  type = bool
}

variable "copy_tags_to_snapshot" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "skip_final_snapshot" {
  type  = bool
}

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

variable "kms_key_id_arn_default_secondary_region" {
  type = string
}

# 8. comprehend and sagemaker cluster role association variables
variable "comprehend_feature_name" {
  type = string
}

variable "sagemaker_feature_name" {
  type = string
}
