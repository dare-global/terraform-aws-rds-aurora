locals {
  serverless_enabled = var.engine_mode == "serverless"
}

resource "aws_rds_cluster" "main" {
  cluster_identifier        = var.cluster_name_prefix_enabled ? null : var.name_prefix
  cluster_identifier_prefix = var.cluster_name_prefix_enabled ? "${var.name_prefix}-" : null

  engine         = var.engine
  engine_mode    = var.engine_mode
  engine_version = local.serverless_enabled ? null : var.engine_version

  cluster_members       = var.cluster_members
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  database_name         = var.database_name

  master_username = var.master_username
  master_password = var.master_password == "" ? random_password.db_master_pass.result : var.master_password

  kms_key_id = var.kms_key_id

  network_type         = var.network_type
  enable_http_endpoint = var.enable_http_endpoint

  port                            = var.port
  db_subnet_group_name            = var.db_subnet_group_name == null ? aws_db_subnet_group.main[0].name : var.db_subnet_group_name
  db_cluster_parameter_group_name = var.create_parameter_group ? aws_rds_cluster_parameter_group.main[0].id : var.db_cluster_parameter_group_name

  deletion_protection = var.deletion_protection

  enable_global_write_forwarding = var.enable_global_write_forwarding

  apply_immediately = var.apply_immediately

  allocated_storage = var.allocated_storage

  vpc_security_group_ids = compact(concat([aws_security_group.main[0].id], var.vpc_security_group_ids))

  backup_retention_period = var.backup_retention_period

  iops              = var.iops
  storage_encrypted = var.storage_encrypted

  enabled_cloudwatch_logs_exports = [for log in var.enabled_cloudwatch_logs_exports : log.name]

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  snapshot_identifier       = var.snapshot_identifier

  source_region = var.source_region
  storage_type  = var.storage_type

  preferred_backup_window      = local.serverless_enabled ? null : var.preferred_backup_window
  preferred_maintenance_window = local.serverless_enabled ? null : var.preferred_maintenance_window

  replication_source_identifier = var.replication_source_identifier

  allow_major_version_upgrade = var.allow_major_version_upgrade

  tags = merge(var.tags, var.cluster_tags)

  dynamic "s3_import" {
    for_each = length(var.s3_import) > 0 && !local.serverless_enabled ? [var.s3_import] : []
    content {
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = try(s3_import.value.bucket_prefix, null)
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  dynamic "restore_to_point_in_time" {
    for_each = length(var.restore_to_point_in_time) > 0 ? [var.restore_to_point_in_time] : []

    content {
      restore_to_time            = try(restore_to_point_in_time.value.restore_to_time, null)
      restore_type               = try(restore_to_point_in_time.value.restore_type, null)
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      use_latest_restorable_time = try(restore_to_point_in_time.value.use_latest_restorable_time, null)
    }
  }

  dynamic "scaling_configuration" {
    for_each = length(var.scaling_configuration) > 0 && local.serverless_enabled ? [var.scaling_configuration] : []

    content {
      auto_pause               = try(scaling_configuration.value.auto_pause, null)
      max_capacity             = try(scaling_configuration.value.max_capacity, null)
      min_capacity             = try(scaling_configuration.value.min_capacity, null)
      seconds_until_auto_pause = try(scaling_configuration.value.seconds_until_auto_pause, null)
      timeout_action           = try(scaling_configuration.value.timeout_action, null)
    }
  }

  dynamic "serverlessv2_scaling_configuration" {
    for_each = length(var.serverlessv2_scaling_configuration) > 0 && var.engine_mode == "provisioned" ? [var.serverlessv2_scaling_configuration] : []

    content {
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
    }
  }

  lifecycle {
    ignore_changes = [
      master_username,
      master_password,
      snapshot_identifier,
      replication_source_identifier,
      global_cluster_identifier
    ]
  }

  timeouts {
    create = try(var.cluster_timeouts.create, null)
    update = try(var.cluster_timeouts.update, null)
    delete = try(var.cluster_timeouts.delete, null)
  }
}

resource "aws_rds_cluster_instance" "main" {
  count = var.replica_count

  identifier         = try(var.instances_parameters[count.index].instance_name, "${var.name_prefix}-${count.index + 1}")
  cluster_identifier = aws_rds_cluster.main.id

  ca_cert_identifier = var.ca_cert_identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = try(var.instances_parameters[count.index].instance_class, var.instance_class)
  promotion_tier = try(var.instances_parameters[count.index].instance_promotion_tier, count.index + 1)

  publicly_accessible = var.publicly_accessible

  db_subnet_group_name    = var.db_subnet_group_name == "" ? aws_db_subnet_group.main[0].name : var.db_subnet_group_name
  db_parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.main[0].id : var.db_parameter_group_name

  apply_immediately = var.apply_immediately

  monitoring_role_arn = var.monitoring_role_enabled ? try(aws_iam_role.rds_enhanced_monitoring[0].arn, null) : var.monitoring_role_arn
  monitoring_interval = var.monitoring_interval

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  preferred_maintenance_window = var.preferred_maintenance_window

  tags = merge(
    var.tags,
    var.cluster_instance_tags
  )

  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }

  timeouts {
    create = try(var.instance_timeouts.create, null)
    update = try(var.instance_timeouts.update, null)
    delete = try(var.instance_timeouts.delete, null)
  }
}

resource "aws_rds_cluster_endpoint" "main" {
  for_each = { for k, v in var.endpoints : k => v && !local.serverless_enabled }

  cluster_endpoint_identifier = each.value.identifier
  cluster_identifier          = aws_rds_cluster.main.id
  custom_endpoint_type        = each.value.type

  excluded_members = try(each.value.excluded_members, null)
  static_members   = try(each.value.static_members, null)

  tags = merge(
    var.tags,
    try(each.value.tags, {})
  )

  depends_on = [
    aws_rds_cluster_instance.main
  ]
}

resource "aws_rds_cluster_role_association" "main" {
  for_each = { for k, v in var.iam_roles : k => v && !local.serverless_enabled }

  db_cluster_identifier = aws_rds_cluster.main.id
  feature_name          = each.value.feature_name
  role_arn              = each.value.role_arn
}

resource "aws_rds_cluster_parameter_group" "main" {
  count = var.create_parameter_group ? 1 : 0

  name_prefix = "${var.name_prefix}-aurora-rds-cluster-"
  family      = var.engine_parameter_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-aurora-rds-cluster",
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "main" {
  count = var.create_parameter_group ? 1 : 0


  name_prefix = "${var.name_prefix}-aurora-rds-instance-"
  family      = var.engine_parameter_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-aurora-rds-instance",
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "main" {
  count = var.db_subnet_group_name == null ? 1 : 0

  name_prefix = "${var.name_prefix}-"
  description = "DB Subnet Group For Aurora cluster ${var.name_prefix}"
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = var.name_prefix
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "db_master_pass" {
  length           = 20
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}
