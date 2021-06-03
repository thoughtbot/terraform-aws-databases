# RDS, Postgres Engine

This module will provision a Postgres database using RDS.

Resources:

* An RDS database instance
* Subnets and security rules to allow access to the database

Outputs:

* The RDS instance
* A `DATABASE_URL` usable by Rails configurations
