####
# Global
####
variable "name_prefix" {
  type        = string
  description = "Name to prefix provisioned resources."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

####
# Cluster
####
variable "cluster_name_prefix_enabled" {
  description = "Whether to use `name` as a prefix for the cluster"
  type        = bool
  default     = false
}

variable "engine" {
  type        = string
  default     = "aurora-postgresql"
  description = <<EOT
  The name of the database engine to be used for this DB cluster.
  Defaults to aurora-postgresql. Valid Values: aurora, aurora-mysql, aurora-postgresql, mysql, postgres. (
  Note that mysql and postgres are Multi-AZ RDS clusters).
  EOT
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: global, parallelquery, provisioned, serverless."
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  type        = string
  description = "Database engine version."
}

variable "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  type        = list(string)
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Cluster `tags` to snapshots"
  type        = bool
  default     = null
}

variable "database_name" {
  type        = string
  description = "Identifier for database"
  default     = "main"
}

variable "master_username" {
  type        = string
  default     = "postgres"
  description = "Username for db admin/master user. Defaults to 'postgres'"
}

variable "master_password" {
  type        = string
  default     = ""
  description = "Password for db admin/master user. Defaults to a random cryptographically secure password."
}

variable "kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key."
  default     = null
}

variable "network_type" {
  type        = string
  description = "The network type of the cluster. Valid values: IPV4, DUAL"
  default     = null
}

variable "enable_http_endpoint" {
  description = "Enable HTTP endpoint (data API). Only valid when engine_mode is set to `serverless`"
  type        = bool
  default     = null
}

variable "port" {
  type        = number
  description = "Port of the RDS instance. Defaults to 5432"
  default     = 5432
}

variable "enable_global_write_forwarding" {
  description = "Whether cluster should forward writes to an associated global cluster. Applied to secondary clusters to enable them to forward writes to an `aws_rds_global_cluster`'s primary cluster"
  type        = bool
  default     = null
}

variable "deletion_protection" {
  type        = bool
  description = "If the DB instance should have deletion protection enabled. Defaults to true."
  default     = true
}

variable "apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = false
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gibibytes. If max_allocated_storage is configured, this argument represents the initial storage allocation and differences from the configuration will be ignored automatically when Storage Autoscaling occurs."
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG we create in this module"
  type        = list(string)
  default     = []
}

variable "backup_retention_period" {
  description = "Days to retain backups. Defaults to 7"
  type        = number
  default     = 7
}

variable "iops" {
  type        = number
  description = "The amount of Provisioned IOPS (input/output operations per second) to be initially allocated for each DB instance in the Multi-AZ DB cluster. For information about valid Iops values, see https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#USER_PIOPS to improve performance in the Amazon RDS User Guide. (This setting is required to create a Multi-AZ DB cluster). Must be a multiple between .5 and 50 of the storage amount for the DB cluster."
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the underlying storage layer should be encrypted"
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of object which define log types to export to AWS Cloudwatch. See in examples."
  type        = list(any)
  default     = []
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
  type        = bool
  default     = null
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
  type        = string
  default     = null
}

variable "source_region" {
  description = "The source region for an encrypted replica DB cluster"
  type        = string
  default     = null
}

variable "storage_type" {
  type        = string
  description = "Specifies the storage type to be associated with the DB cluster. Defaults to io1"
  default     = null
}

variable "cluster_tags" {
  description = "Additional tags for the cluster"
  type        = map(string)
  default     = {}
}

variable "replication_source_identifier" {
  description = "ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica"
  type        = string
  default     = null
}

variable "s3_import" {
  description = "Restore from a Percona XtraBackup stored in S3 bucket. Only Aurora MySQL is supported."
  type        = map(string)
  default     = {}
}

variable "restore_to_point_in_time" {
  description = "Restore to point in time configuration. See docs for arguments https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster#restore_to_point_in_time-argument-reference"
  type        = map(string)
  default     = {}
}

variable "scaling_configuration" {
  description = "Map of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`"
  type        = map(string)
  default     = {}
}

variable "serverlessv2_scaling_configuration" {
  description = "Map of nested attributes with serverless v2 scaling properties. Only valid when `engine_mode` is set to `provisioned`"
  type        = map(string)
  default     = {}
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled using the `backup_retention_period` parameter. Time in UTC"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30"
  type        = string
  default     = null
}

#####
# Cluster instance/s
#####
variable "instance_class" {
  type        = string
  description = "Instance class of DB e.g. db.t4g.medium. Defaults to serverless."
  default     = "db.t4g.medium"
}

variable "replica_count" {
  description = "Number of reader nodes to create."
  type        = number
  default     = 1
}

variable "instances_parameters" {
  description = "Individual settings for instances."
  type        = any
  default     = []
}

variable "publicly_accessible" {
  description = "Whether the DB should have a public IP address"
  type        = bool
  default     = null
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Whether to enable RDS performance insights. Defaults to true"
  type        = bool
  default     = null
}

variable "performance_insights_kms_key_id" {
  description = "KMS key for performance insights"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Number of days to retain performance insights information. Defaults to 7"
  type        = number
  default     = null
}

variable "cluster_instance_tags" {
  description = "Additional tags for the cluster instance"
  type        = map(string)
  default     = {}
}

variable "instance_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster instance(s)"
  type        = map(string)
  default     = {}
}

#####
# Subnet Group/s
#####
variable "db_subnet_group_name" {
  description = "The existing subnet group name to use"
  type        = string
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of VPC subnet IDs."
}

#####
# Parameter Group/s
#####
variable "create_parameter_group" {
  type        = bool
  description = "Whether to create parameter groups for RDS cluster and RDS instances"
  default     = true
}

variable "engine_parameter_family" {
  type        = string
  description = "The database engine paramater group family"
  default     = "postgres14"
}

variable "db_cluster_parameter_group_name" {
  description = "The name of a DB Cluster parameter group to use"
  type        = string
  default     = null
}

variable "cluster_parameters" {
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default     = []
}

variable "db_parameter_group_name" {
  description = "The name of a DB parameter group to use"
  type        = string
  default     = null
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "A list of parameter objects"
  default     = []
}

#####
# Security Group
#####
variable "create_security_group" {
  description = "Whether to create security group for RDS cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for instance"
}

variable "revoke_rules_on_delete" {
  description = <<EOT
  Instruct Terraform to revoke all of the Security Groups attached
  ingress and egress rules before deleting the rule itself.
  Defaults to true
  EOT
  type        = bool
  default     = true
}

variable "cidr_blocks" {
  description = "main cidr blocks for ingress"
  type        = list(string)
  default     = []
}

variable "security_group_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}

#####
# Cluster endpoints
#####
variable "endpoints" {
  description = "Map of additional cluster endpoints and their attributes to be created"
  type        = any
  default     = {}
}

#####
# IAM Roles
#####
variable "iam_roles" {
  description = "Map of IAM roles and supported feature names to associate with the cluster"
  type        = map(map(string))
  default     = {}
}

variable "monitoring_role_enabled" {
  description = "Determines whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = ""
}

variable "iam_role_description" {
  description = "Description to apply to IAM role. Optional"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_managed_policy_arns" {
  description = "ARNs of managed policies for enhanced monitoring IAM user"
  type        = list(string)
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the monitoring role"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any policies the monitoring role has before destroying it"
  type        = bool
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the monitoring role"
  type        = number
  default     = null
}
