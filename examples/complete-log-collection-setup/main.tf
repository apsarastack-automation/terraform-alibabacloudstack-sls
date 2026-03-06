module "sls_complete" {
  source = "../../modules/sls_cluster"

  project_name = var.project_name
  description  = var.description

  # Log store configuration
  log_store_name        = var.log_store_name
  shard_count           = var.shard_count
  retention_period      = var.retention_period
  auto_split            = var.auto_split
  max_split_shard_count = var.max_split_shard_count
  append_meta           = var.append_meta
  enable_web_tracking   = var.enable_web_tracking

  # Index configuration
  full_text_index      = var.full_text_index
  field_search_indexes = var.field_search_indexes

  # Machine groups and Logtail
  machine_groups      = var.machine_groups
  logtail_configs     = var.logtail_configs
  logtail_attachments = var.logtail_attachments
}
