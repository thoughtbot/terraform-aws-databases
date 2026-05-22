locals {
  normalized_cluster_name = replace(var.cluster_name, "-", "_")

  connector_name = coalesce(
    var.connector_name,
    "${var.cluster_name}-postgres-connector"
  )

  worker_configuration_name = coalesce(
    var.worker_configuration_name,
    "${var.cluster_name}-worker-config"
  )

  log_group_name = coalesce(
    var.log_group_name,
    "${local.connector_name}-logs"
  )

  schema_history_topic = coalesce(
    var.schema_history_topic,
    "schemahistory.${local.normalized_cluster_name}"
  )

  worker_configuration_properties_file_content = coalesce(
    var.worker_configuration_properties_file_content,
    <<-EOT
    key.converter=org.apache.kafka.connect.storage.StringConverter
    value.converter=org.apache.kafka.connect.storage.StringConverter
    config.providers=secretsmanager,ssm
    config.providers.secretsmanager.class=com.amazonaws.kafka.config.providers.SecretsManagerConfigProvider
    config.providers.ssm.class=com.amazonaws.kafka.config.providers.SsmParamStoreConfigProvider
    config.providers.secretsmanager.param.region=${data.aws_region.this.region}
    config.providers.ssm.param.region=${data.aws_region.this.region}
    EOT
  )

  default_connector_configuration = {
    "connector.class"                                                     = "io.debezium.connector.postgresql.PostgresConnector"
    "database.dbname"                                                     = "$${secretsmanager:${var.database_credentials_secret_name}:dbname}"
    "database.hostname"                                                   = "$${secretsmanager:${var.database_credentials_secret_name}:host}"
    "database.password"                                                   = "$${secretsmanager:${var.database_credentials_secret_name}:password}"
    "database.port"                                                       = "$${secretsmanager:${var.database_credentials_secret_name}:port}"
    "database.user"                                                       = "$${secretsmanager:${var.database_credentials_secret_name}:username}"
    "plugin.name"                                                         = "pgoutput"
    "publication.name"                                                    = "dbz_publication_${local.normalized_cluster_name}"
    "schema.history.internal.consumer.sasl.client.callback.handler.class" = "software.amazon.msk.auth.iam.IAMClientCallbackHandler"
    "schema.history.internal.consumer.sasl.jaas.config"                   = "software.amazon.msk.auth.iam.IAMLoginModule required;"
    "schema.history.internal.consumer.sasl.mechanism"                     = "AWS_MSK_IAM"
    "schema.history.internal.consumer.security.protocol"                  = "SASL_SSL"
    "schema.history.internal.kafka.bootstrap.servers"                     = "$${ssm:${var.kafka_iam_broker_endpoint_parameter_name}}"
    "schema.history.internal.kafka.topic"                                 = local.schema_history_topic
    "schema.history.internal.producer.sasl.client.callback.handler.class" = "software.amazon.msk.auth.iam.IAMClientCallbackHandler"
    "schema.history.internal.producer.sasl.jaas.config"                   = "software.amazon.msk.auth.iam.IAMLoginModule required;"
    "schema.history.internal.producer.sasl.mechanism"                     = "AWS_MSK_IAM"
    "schema.history.internal.producer.security.protocol"                  = "SASL_SSL"
    "slot.name"                                                           = "debezium_${local.normalized_cluster_name}"
    "table.include.list"                                                  = var.table_include_list
    "tasks.max"                                                           = tostring(var.tasks_max)
    "topic.creation.default.cleanup.policy"                               = "compact"
    "topic.creation.default.partitions"                                   = "-1"
    "topic.creation.default.replication.factor"                           = "-1"
    "topic.prefix"                                                        = local.normalized_cluster_name
  }
}

data "aws_mskconnect_custom_plugin" "this" {
  name = var.custom_plugin_name
}

resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group_name
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.tags
}

resource "aws_mskconnect_worker_configuration" "this" {
  name                    = local.worker_configuration_name
  properties_file_content = local.worker_configuration_properties_file_content
}

resource "aws_mskconnect_connector" "this" {
  name                 = local.connector_name
  kafkaconnect_version = var.kafkaconnect_version

  capacity {
    autoscaling {
      mcu_count        = var.mcu_count
      min_worker_count = var.min_worker_count
      max_worker_count = var.max_worker_count

      scale_in_policy {
        cpu_utilization_percentage = 20
      }

      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }

  connector_configuration = merge(
    local.default_connector_configuration,
    var.connector_configuration_overrides
  )

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = var.bootstrap_brokers_sasl_iam

      vpc {
        security_groups = var.security_group_ids
        subnets         = var.subnet_ids
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "IAM"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.this.name
      }
    }
  }

  plugin {
    custom_plugin {
      arn      = data.aws_mskconnect_custom_plugin.this.arn
      revision = data.aws_mskconnect_custom_plugin.this.latest_revision
    }
  }

  service_execution_role_arn = aws_iam_role.this.arn

  worker_configuration {
    arn      = aws_mskconnect_worker_configuration.this.arn
    revision = aws_mskconnect_worker_configuration.this.latest_revision
  }
}
