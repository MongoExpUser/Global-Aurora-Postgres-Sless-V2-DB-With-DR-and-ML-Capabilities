# ***************************************************************************************************************************************
# *  stg.auto.tfvars                                                                                                                    *
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
org_name                                  = "org"
project_name                              = "proj"
region                                    = "us-east-1"
creator                                   = "terraform"
environment                               = "stg"
map_migrated                              = "map-migrated-value"
service_provider                          = "provider"
primary_region                            = "us-east-1"
secondary_region                          = "us-west-2"

# 1. credentials-related  variables
random_password_length                    = 10
random_password_true                      = true
random_password_override_special          = "!#$&*()-_=[]{}<>:?"
recovery_window_in_days                   = 7
secret_description                        = "Aurora Postgres DB Credentials"
aws_secretsmanager_secret_name            = "pgs-secret"

# 2. security group variables
security_group_name                       = "pgs-sg"
security_group_description                = "Allow Access to DB and SSH ports"
vpc_id_primary                            = "vpc-id-primary-region"
vpc_id_secondary                          = "vpc-id-secondary-region"
ingress_ssh_description                   = "SSH Port Access from with the VPC CIDR"
ingress_ssh_port                          = 22
ingress_protocol                          = "tcp"
ingress_cidr_blocks_primary               = ["cidr-value-primary-region"]
ingress_cidr_blocks_secondary             = ["cidr-value-secondary-region"]
ingress_db_description                    = "Postgres Port Access from with the VPC CIDR"
ingress_db_port                           = 5432
egress_port                               = 0
egress_protocol                           = "-1"
egress_cidr_blocks                        = ["0.0.0.0/0"]

# 3. db subnet group variables
db_subnet_group_description               = "Aurora DB Subnet Group"
db_subnet_group_name                      = "pgs-db-subnet-grp"
db_subnet_ids_primary                     = ["subnet-1-primary-region", "subnet-2-primary-region", "subnet-3-primary-region"]
db_subnet_ids_secondary                   = ["subnet-1-secondary-region", "subnet-2-secondary-region", "subnet-3-secondary-region"]

# 4. cluster parameter group variables
cluster_parameter_group_name              = "pgs-cluster-param-grp"
cluster_parameter_group_family            = "aurora-postgresql15"
cluster_parameter_group_description       = "Aurora Cluster Parameter Group"
cluster_apply_method                      = "pending-reboot"
cluster_timezone						              = "UTC" # or "US/Eastern"  or "US/Central", or "America/Denver", or "US/Pacific", etc.
cluster_orafce_timezone                   = "UTC" # or "US/Eastern"  or "US/Central", or "America/Denver", or "US/Pacific", etc.

# 5. db/instance parameter group variables
db_parameter_group_name                   = "pgs-db-instance-param-grp"
db_parameter_group_family                 = "aurora-postgresql15"
db_parameter_group_description            = "Aurora DB Instance Parameter Group"
db_apply_method                           = "pending-reboot"
db_shared_preload_libraries               = "pg_stat_statements,pg_cron"

# 6 . I AM role variable(s)
rds_monitoring_role_name                  = "pgs-rds-monitoring-role"
aurora_comprehend_role_name               = "pgs-aurora-comprehend-role"
aurora_sagemaker_role_name                = "pgs-aurora-sagemaker-role"

# 7. aurora postgresql serverless cluster(s) and cluster instance(s) variables
sleep_time                                = "120s"
global_cluster_identifier                 = "global-database"
cluster_identifier_primary                = "primary-cluster"
cluster_identifier_secondary              = "secondary-cluster"
cluster_instance_identifiers_primary      = ["utc-writer-instance", "utc-reader-instance-1"]
cluster_instance_identifiers_secondary    = ["utc-reader-instance-2"]
instance_class                            = "db.serverless"
engine                                    = "aurora-postgresql"
engine_mode                               = "provisioned"
engine_version                            = "15.2"
username                                  = "postgres"
backup_retention_period                   = 7
preferred_backup_window                   = "05:05-07:35"
preferred_maintenance_window              = "sun:14:05-sun:16:35"
enabled_cloudwatch_logs_exports           = ["postgresql"]
storage_encrypted                         = true
publicly_accessible                       = false
performance_insights_enabled              = true
monitoring_interval                       = 60
allow_major_version_upgrade               = false
auto_minor_version_upgrade                = true
apply_immediately                         = true
copy_tags_to_snapshot                     = true
deletion_protection                       = false
skip_final_snapshot                       = true
max_capacity                              = 1
min_capacity                              = 0.5
kms_key_id_arn_default_secondary_region   = "arn:aws:kms:us-west-2:account-id:key/string-value"

# 8. comprehend and sagemaker cluster role association variable
comprehend_feature_name                   = "Comprehend"
sagemaker_feature_name                    = "SageMaker"
