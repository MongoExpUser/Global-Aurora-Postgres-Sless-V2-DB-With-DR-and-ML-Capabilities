[![CI - TF Deploy AuoraPgsGlobalSless2](https://github.com/MongoExpUser/Global-DB-Aurora-Postgres-Sless-V2-With-DR-and-ML-Capabilities/actions/workflows/global-aurora-pgs-sless-v2-dr-ml.yml/badge.svg)](https://github.com/MongoExpUser/Global-DB-Aurora-Postgres-Sless-V2-With-DR-and-ML-Capabilities/actions/workflows/global-aurora-pgs-sless-v2-dr-ml.yml)

## Global-DB-Aurora-Postgres-Sless-V2-With-DR-and-ML-Capabilities
  
          
## Purpose
 * Deploy a Global Auora Postgres Serverless V2 Database Cluster with Disaster Recovery (DR) and In-Database Machine Learning Capabilities
   Machine Learning Features include:
   * AWS Comprehend for Sentiment Analysis.
   * AWS SageMaker Machine with Linear Learner, Random Forest & Xboost algorithms features.

## Advantage of Global Cluster
  * The global database ensures Cross-Region Disaster Recovery, hence:
    * If the primary (source) region suffers an outage, the secondary region cluster can be promoted to a stand alone primary cluster.
    * The cluster can recover in "less than 1 minute" with an effective <strong>Recovery Point Objective (RPO) of 1 second</strong> and a <strong>Recovery Time Objective (RTO) of less than 1 minute.</strong>

## Deployed Resources:
  * The following resources are deployed:
    * AWS Secret Manager Secret
    * AWS VPC Security Group
    * AWS RDS DB Subnet Group
    * AWS RDS Cluster Parameter Group
    * AWS RDS DB Parameter Group
    * AWS RDS Enhanced Monitoring IAM Role
    * AWS Aurora Postgres Cluster-Comprehend IAM Role
    * AWS Aurora Postgres Cluster-Sagemaker IAM Role
    * AWS Aurora PostgreSQL Serverless Global Cluster
    * AWS Aurora PostgreSQL Serverless Primary and Secondary Clusters (on the Global Cluster) and Related Primary and Reader DB Instances
    * AWS RDS Cluster Role Associations for Associating Cluster with AWS Comprehend on the Primary and Secondary Clusters
    * AWS RDS Cluster Role Associations for Associating Cluster with AWS SageMaker on the Primary and Secondary Clusters
  
  

# License
Copyright © 2023. MongoExpUser
