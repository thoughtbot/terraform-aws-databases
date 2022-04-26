# AWS Database Modules for Terraform

Provision databases on AWS with policies and security groups suitable for use by
pods in an EKS cluster.

Modules:

* [Postgres](./rds-postgres/README.md) (RDS)
  * [Primary Instance](./rds-postgres/primary-instance/README.md)
  * [Admin Login](./rds-postgres/admin-login/README.md)
  * [User Login](./rds-postgres/user-login/README.md)
* [Redis](./elasticacahe-redis/README.md) (ElastiCache)
  * [Cluster](./elasticacahe-redis/cluster/README.md)
