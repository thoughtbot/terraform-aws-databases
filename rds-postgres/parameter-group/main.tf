locals {
  version_components = split(".", var.engine_version)
  postgres_family = join(
    "",
    [
      "postgres",
      (
        local.version_components[0] == "9" ?
        join(".", [local.version_components[0], local.version_components[1]]) :
        local.version_components[0]
      )
    ]
  )
  parameter = merge({"rds.force_ssl" = var.force_ssl ? 1 : 0}, var.parameter)
}

resource "aws_db_parameter_group" "this" {
  name   = var.name
  family = local.postgres_family
  tags   = var.tags

  dynamic "parameter" {
    for_each = local.parameter

    content {
      name = parameter.key
      value = parameter.value
    }
  }
}
