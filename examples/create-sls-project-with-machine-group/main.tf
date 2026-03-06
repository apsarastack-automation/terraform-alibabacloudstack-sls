module "sls_project_with_machine_group" {
  source = "../../modules/sls_cluster"

  project_name = var.project_name
  description  = var.description

  # Log store configuration
  log_store_name        = var.log_store_name
  shard_count           = var.shard_count
  retention_period      = var.retention_period
  auto_split            = var.auto_split
  max_split_shard_count = var.max_split_shard_count

  # Machine groups configuration
  machine_groups = var.machine_groups

  # Logtail configs
  logtail_configs = var.logtail_configs

  # Logtail attachments
  logtail_attachments = var.logtail_attachments
}
