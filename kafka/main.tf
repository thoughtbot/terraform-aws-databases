resource "aws_msk_cluster" "this" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = local.broker_node_count

  broker_node_group_info {
    instance_type   = var.instance_type
    ebs_volume_size = var.ebs_volume_size
    client_subnets  = module.network.private_subnet_ids
    security_groups = [aws_security_group.this.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.this.arn

    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.this.name
      }
      firehose {
        enabled = false
      }
      s3 {
        enabled = false
      }
    }
  }

  tags = var.tags
}

module "network" {
  source = "github.com/thoughtbot/flightdeck//aws/network-data?ref=v0.9.2"

  private_tags = var.private_tags
  public_tags  = var.public_tags
  vpc_tags     = var.vpc_tags
}

module "additional_vpc" {
  count  = length(keys(var.additional_vpc_tags)) == 0 ? 0 : 1
  source = "github.com/thoughtbot/flightdeck//aws/network-data?ref=v0.9.2"

  vpc_tags = var.additional_vpc_tags
}

resource "aws_security_group" "this" {
  name   = "${var.cluster_name}-sg"
  vpc_id = module.network.vpc.id

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = local.all_cidr_blocks
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    description = "plaintext"
    protocol    = "tcp"
    cidr_blocks = local.all_cidr_blocks
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    description = "tls-encrypted"
    protocol    = "tcp"
    cidr_blocks = local.all_cidr_blocks
  }

  ingress {
    from_port   = -1
    to_port     = -1
    description = "icmp"
    protocol    = "icmp"
    cidr_blocks = local.all_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = local.all_cidr_blocks
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "msk-sg"
  }
}

resource "aws_kms_key" "this" {
  description = "${var.cluster_name}-kms-key"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.cluster_name}-broker-logs"
  retention_in_days = 14
}

locals {
  broker_node_count      = coalesce(var.broker_node_count, length(module.network.private_subnet_ids))
  additional_cidr_blocks = length(keys(var.additional_vpc_tags)) == 0 ? [] : one(module.additional_vpc[*].cidr_blocks)
  all_cidr_blocks        = concat(module.network.cidr_blocks, local.additional_cidr_blocks)
}
