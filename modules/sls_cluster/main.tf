# --- SLS Project Resource ---

resource "alibabacloudstack_log_project" "default" {
  name        = var.project_name
  description = var.description
}

# --- SLS Log Store Resources ---

resource "alibabacloudstack_log_store" "default" {
  project               = local.sls_project_name
  name                  = var.log_store_name
  shard_count           = var.shard_count
  retention_period      = var.retention_period
  auto_split            = var.auto_split
  max_split_shard_count = var.max_split_shard_count
  append_meta           = var.append_meta
  enable_web_tracking   = var.enable_web_tracking

  lifecycle {
    precondition {
      condition     = var.shard_count >= 1 && var.shard_count <= 100
      error_message = "Log store ${var.log_store_name}: shard_count must be between 1 and 100."
    }
    precondition {
      condition     = var.retention_period >= 1 && var.retention_period <= 3650
      error_message = "Log store ${var.log_store_name}: retention_period must be between 1 and 3650 days."
    }
    precondition {
      condition     = !var.auto_split || (var.max_split_shard_count >= var.shard_count)
      error_message = "Log store ${var.log_store_name}: max_split_shard_count must be greater than or equal to shard_count when auto_split is enabled."
    }
  }
}

locals {
  # The actual project name (either newly created or pre-existing)
  sls_project_name = alibabacloudstack_log_project.default.name
  sls_store_name   = alibabacloudstack_log_store.default.name
  sls_store_id     = alibabacloudstack_log_store.default.id
}

# --- SLS Log Store Index Resources ---

locals {
  create_log_store_index = var.full_text_index != null || length(var.field_search_indexes) > 0
}

resource "alibabacloudstack_log_store_index" "default" {
  count    = local.create_log_store_index ? 1 : 0
  project  = local.sls_project_name
  logstore = local.sls_store_name

  dynamic "full_text" {
    for_each = var.full_text_index != null ? [var.full_text_index] : []
    content {
      case_sensitive  = full_text.value.case_sensitive
      include_chinese = full_text.value.include_chinese
      token           = full_text.value.token
    }
  }

  dynamic "field_search" {
    for_each = var.field_search_indexes
    content {
      name             = field_search.value.name
      type             = field_search.value.type
      alias            = field_search.value.alias
      case_sensitive   = field_search.value.case_sensitive
      include_chinese  = field_search.value.include_chinese
      token            = field_search.value.token
      enable_analytics = field_search.value.enable_analytics
    }
  }

  depends_on = [alibabacloudstack_log_store.default]
}

# --- SLS Machine Group Resources ---

resource "alibabacloudstack_log_machine_group" "default" {
  for_each      = var.machine_groups
  project       = local.sls_project_name
  name          = each.key
  identify_type = each.value.identify_type
  identify_list = each.value.identify_list
  topic         = each.value.topic

  lifecycle {
    precondition {
      condition     = length(each.value.identify_list) > 0
      error_message = "Machine group ${each.key}: identify_list must contain at least one identifier."
    }
    precondition {
      condition     = contains(["ip", "userdefined"], each.value.identify_type)
      error_message = "Machine group ${each.key}: identify_type must be either 'ip' or 'userdefined'."
    }
  }
}

# --- SLS Logtail Config Resources ---

resource "alibabacloudstack_logtail_config" "default" {
  for_each     = var.logtail_configs
  project      = local.sls_project_name
  logstore     = local.sls_store_name
  name         = each.key
  input_type   = each.value.input_type
  output_type  = each.value.output_type
  input_detail = each.value.input_detail

  lifecycle {
    precondition {
      condition     = contains(["file", "plugin"], each.value.input_type)
      error_message = "Logtail config ${each.key}: input_type must be either 'file' or 'plugin'."
    }
    precondition {
      condition     = each.value.output_type == "LogService"
      error_message = "Logtail config ${each.key}: output_type must be 'LogService'."
    }
  }

  depends_on = [alibabacloudstack_log_store.default]
}

# --- SLS Logtail Attachment Resources ---

resource "alibabacloudstack_logtail_attachment" "default" {
  for_each            = var.logtail_attachments
  project             = local.sls_project_name
  logtail_config_name = alibabacloudstack_logtail_config.default[each.value.logtail_config_name].name
  machine_group_name  = alibabacloudstack_log_machine_group.default[each.value.machine_group_name].name

  lifecycle {
    precondition {
      condition     = contains(keys(var.logtail_configs), each.value.logtail_config_name)
      error_message = "Logtail attachment ${each.key}: logtail_config_name '${each.value.logtail_config_name}' must be defined in logtail_configs variable."
    }
    precondition {
      condition     = contains(keys(var.machine_groups), each.value.machine_group_name)
      error_message = "Logtail attachment ${each.key}: machine_group_name '${each.value.machine_group_name}' must be defined in machine_groups variable."
    }
  }

  depends_on = [
    alibabacloudstack_logtail_config.default,
    alibabacloudstack_log_machine_group.default
  ]
}
