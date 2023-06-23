# ***************************************************************************************************************************************
# *  outputs.tf                                                                                                                         *
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


# 1.
output "db_credentials_key_value" {
  description = "key-value pair of the master user's credentials (username and password)"
  value = jsondecode(aws_secretsmanager_secret_version.created.secret_string)
  sensitive = true
}

# 2a.
output "db_security_group_primary_attributes" {
  description = "key-value pair attributes of the created db security group - primary cluster"
  value = aws_security_group.created_primary
}

# 2b.
output "db_security_group_secondary_attributes" {
  description = "key-value pair attributes of the created db security group - secondary cluster"
  value = aws_security_group.created_secondary
}

# 3a.
output "db_subnet_group_primary_attributes" {
  description = "key-value pair attributes of the created db subnet group - primary cluster"
  value = aws_db_subnet_group.created_primary
}

# 3b.
output "db_subnet_group_secondary_attributes" {
  description = "key-value pair attributes of the created db subnet group - secondary cluster"
  value = aws_db_subnet_group.created_secondary
}

# 4a.
output "cluster_parameter_group_primary_attributes" {
  description = "key-value pair attributes of the created cluster parameter group - primary cluster"
  value = aws_rds_cluster_parameter_group.created_primary
}

# 4b.
output "cluster_parameter_group_secondary_attributes" {
  description = "key-value pair attributes of the created cluster parameter group - secondary cluster"
  value = aws_rds_cluster_parameter_group.created_secondary
}


# 5a.
output "db_parameter_group_primary_attributes" {
  description = "key-value pair attributes of the created db parameter group - primary cluster"
  value = aws_db_parameter_group.created_primary
}

# 5b.
output "db_parameter_group_secondary_attributes" {
  description = "key-value pair attributes of the created db parameter group - secondary cluster"
  value = aws_db_parameter_group.created_secondary
}

# 6a.
output "db_monitoring_role_arn" {
  description = "ARN of the created enhanced monitoring role"
  value = aws_iam_role.created_monitoring.arn
}

# 6b.
output "cluster_comprehend_primary_role_arn" {
  description = "ARN of the created db-cluster-comprehend role - primary cluster"
  value = aws_iam_role.created_comprehend_primary.arn
}

# 6c.
output "cluster_sagemaker_primary_role_arn" {
  description = "ARN of the created db-cluster-sagemaker role - primary cluster"
  value = aws_iam_role.created_sagemaker_primary.arn
}


# 6d
output "cluster_comprehend_secondary_role_arn" {
  description = "ARN of the created db-cluster-comprehend role - secondary cluster"
  value = aws_iam_role.created_comprehend_secondary.arn
}

# 6e.
output "cluster_sagemaker_secondary_role_arn" {
  description = "ARN of the created db-cluster-sagemaker role - secondary cluster"
  value = aws_iam_role.created_sagemaker_secondary.arn
}


# 7a.
output "global_cluster_attributes" {
  description = "key-value pair attributes of the created Aurora cluster."
  value = aws_rds_global_cluster.created
  sensitive = true
}

# 7b.
output "cluster_primary_attributes" {
  description = "key-value pair attributes of the created Aurora primary cluster."
  value = aws_rds_cluster.created_primary
  sensitive = true
}

# 7c.
output "cluster_primary_instances_attributes" {
  description = "key-value pair attributes of the created Aurora primary cluster's instance(s)."
  value = aws_rds_cluster_instance.created_primary_instance
  sensitive = true
}

# 7d.
output "cluster_secondary_attributes" {
  description = "key-value pair attributes of the created Aurora secondary cluster."
  value = aws_rds_cluster.created_secondary
  sensitive = true
}

# 7e.
output "cluster_secondary_instances_attributes" {
  description = "key-value pair attributes of the created Aurora secondary cluster's instance(s)."
  value = aws_rds_cluster_instance.created_secondary_instance
  sensitive = true
}


# 8a.
output "cluster_role_association_comprehend_primary_attributes" {
  description = "key-value pair attributes of the created Aurora cluster role association for comprehend feature - primary cluster"
  value = aws_rds_cluster_role_association.created_comprehend_primary
}


# 8b.
output "cluster_role_association_sagemaker_primary_attributes" {
  description = "key-value pair attributes of the created Aurora cluster role association for sagemaker feature - primary cluster"
  value = aws_rds_cluster_role_association.created_sagemaker_primary
}


# 8c.
output "cluster_role_association_comprehend_secondary_attributes" {
  description = "key-value pair attributes of the created Aurora cluster role association for comprehend feature  - secondary cluster"
  value = aws_rds_cluster_role_association.created_comprehend_secondary
}


# 8d.
output "cluster_role_association_sagemaker_secondary_attributes" {
  description = "key-value pair attributes of the created Aurora cluster role association for sagemaker feature - secondary cluster"
  value = aws_rds_cluster_role_association.created_sagemaker_secondary
}
