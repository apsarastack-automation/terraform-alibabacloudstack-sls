# Alibaba Cloud Log Service (SLS) Terraform Module

This module creates and manages Log Service (SLS) projects and core log collection & analysis resources on Alibaba Cloud Stack. It supports:

- **Creating a new SLS project** with a single logstore  
- **Creating a logstore in an existing SLS project** (by specifying an already-existing project name)  
- **Configuring logstore indexes** (full-text index + field-based index) to enable efficient search and analytics  
- **Creating machine groups**, for unified management of log collection sources  
- **Defining Logtail configurations**, and establishing their associations with machine groups (*Logtail Attachments*)

> ⚠️ **Important Notice**: This module **supports only a single logstore** (`log_store_name`) — it does *not* support batch creation of multiple logstores (i.e., the `log_stores` map variable is *not supported*). For multi-logstore scenarios, invoke this module multiple times.

## Features

- ✅ Create or reuse an SLS Project  
- ✅ Create a single Logstore, with fine-grained configuration including shard count, retention period, and auto-splitting  
- ✅ Flexible Logstore indexing: supports full-text indexing (*Full Text*) and structured field-based indexing (*Field Search*)  
- ✅ Define machine groups (IP-based or user-defined identifier type), supporting multiple concurrent groups  
- ✅ Declaratively define Logtail collection configurations (*File* or *Plugin* type), enforcing output to Log Service  
- ✅ Establish associations (*Attachments*) between Logtail configurations and machine groups, supporting many-to-many mappings  
- ✅ Built-in comprehensive validation: all critical input parameters include `precondition` checks to ensure deployment robustness  

## Usage

### Basic Usage: Create a New Project and Logstore

```hcl
module "sls" {
  source = "<Module Path>"

  project_name     = "my-sls-project"
  description      = "A Log Service project managed by Terraform"
  log_store_name   = "app-logs"
  shard_count      = 4
  retention_period = 90
}
```

### Advanced Usage: Create an Indexed Logstore in an Existing Project

```hcl
module "sls" {
  source = "<Module Path>"

  project_name = "existing-project-name"  # Reference to an existing project
  log_store_name = "audit-logs"

  # Full-text index configuration
  full_text_index = {
    case_sensitive  = true
    include_chinese = true
    token           = " ,;=()\t\n"
  }

  # Field-based index configuration
  field_search_indexes = [
    {
      name             = "status"
      type             = "long"
      enable_analytics = true
    },
    {
      name             = "service"
      type             = "text"
      case_sensitive   = false
      include_chinese  = true
    }
  ]
}
```

### Advanced Usage: End-to-End Log Collection Pipeline (Machine Group + Logtail + Attachment)

```hcl
module "sls" {
  source = "<Module Path>"

  project_name = "prod-logs"
  log_store_name = "nginx-access"

  # Define machine group: IP-based server cluster
  machine_groups = {
    nginx_servers = {
      identify_type = "ip"
      identify_list = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
      topic         = "nginx"
    }
  }

  # Define Logtail configuration: collect Nginx access logs
  logtail_configs = {
    nginx_access_config = {
      input_type   = "file"
      output_type  = "LogService"
      input_detail = jsonencode({
        file_path = "/var/log/nginx/access.log"
        log_type  = "common_regexp"
        regex     = "^([^ ]+) ([^ ]+) ([^ ]+) \\[([^\\]]+)\\] \"([^\\\"]+)\" ([^ ]+) ([^ ]+) \"([^\\\"]+)\" \"([^\\\"]+)\""
        keys      = ["remote_addr", "remote_user", "body_bytes_sent", "time_local", "request", "status", "request_time", "http_referer", "http_user_agent"]
      })
    }
  }

  # Associate Logtail configuration with machine group
  logtail_attachments = {
    attach_nginx_to_servers = {
      logtail_config_name = "nginx_access_config"
      machine_group_name  = "nginx_servers"
    }
  }
}
```

## Environment Dependencies

### Terraform Core

| Name      | Version     |
|-----------|-------------|
| Terraform | `>= 1.5.6`  |

### Provider

| Name              | Version                    |
|-------------------|----------------------------|
| alibabacloudstack | `>= 3.18.24, < 3.19.0`     |

## Module Variables

### Input Variables

| Name                      | Description                                                                                                                               | Type                                                                                                                                                   | Default | Required |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|---------|----------|
| `project_name`            | **Name of the SLS project. If the project does not exist, it will be automatically created.**                                             | `string`                                                                                                                                               | —       | Yes      |
| `description`             | Brief description of the SLS project (takes effect only when creating a new project)                                                      | `string`                                                                                                                                               | `""`    | No       |
| `log_store_name`          | **Name of the logstore.**                                                                                                                 | `string`                                                                                                                                               | —       | Yes      |
| `shard_count`             | Initial number of shards for the logstore (valid range: 1–100)                                                                          | `number`                                                                                                                                               | `2`     | No       |
| `retention_period`        | Number of days to retain log data (valid range: 1–3650)                                                                                 | `number`                                                                                                                                               | `30`    | No       |
| `auto_split`              | Whether to enable automatic shard splitting                                                                                               | `bool`                                                                                                                                                 | `false` | No       |
| `max_split_shard_count`   | Maximum number of shards allowed for automatic splitting (only effective when `auto_split = true`)                                      | `number`                                                                                                                                               | `64`    | No       |
| `append_meta`             | Whether to automatically append log metadata fields (e.g., `__topic__`, `__source__`, etc.)                                              | `bool`                                                                                                                                                 | `true`  | No       |
| `enable_web_tracking`     | Whether to enable Web Tracking (for frontend log collection)                                                                              | `bool`                                                                                                                                                 | `false` | No       |
| `full_text_index`         | Full-text index configuration object (`null` disables full-text index creation)                                                           | `object({ case_sensitive = optional(bool), include_chinese = optional(bool), token = optional(string) })`                                            | `null`  | No       |
| `field_search_indexes`    | List of field-based index configurations (empty list disables field index creation)                                                     | `list(object({ name = string, type = optional(string), alias = optional(string), case_sensitive = optional(bool), include_chinese = optional(bool), token = optional(string), enable_analytics = optional(bool) }))` | `[]`    | No       |
| `machine_groups`          | Map from machine group names to their configurations (key = group name; value = `{ identify_type, identify_list, topic }` object)      | `map(object({ identify_type = optional(string), identify_list = list(string), topic = optional(string) }))`                                         | `{}`    | No       |
| `logtail_configs`         | Map from Logtail configuration names to their definitions (key = config name; value = `{ input_type, output_type, input_detail }` object) | `map(object({ input_type = string, output_type = string, input_detail = string }))`                                                                  | `{}`    | No       |
| `logtail_attachments`     | Map from Logtail attachment names to their configurations (key = attachment name; value = `{ logtail_config_name, machine_group_name }` object) | `map(object({ logtail_config_name = string, machine_group_name = string }))`                                                                          | `{}`    | No       |

> 💡 **Key Constraints**:
> - `shard_count` and `retention_period` cannot be *reduced* after logstore creation.  
> - When `auto_split = true`, `max_split_shard_count` must be ≥ `shard_count`.  
> - In `logtail_configs`, `input_type` accepts only `"file"` or `"plugin"`; `output_type` must be `"LogService"`.  
> - In `machine_groups`, `identify_type` accepts only `"ip"` or `"userdefined"`.  
> - In `logtail_attachments`, referenced `logtail_config_name` and `machine_group_name` must exactly match keys defined in `logtail_configs` and `machine_groups`, respectively — typos will cause `precondition` validation failures.

### Output Variables

| Name             | Description                                          |
|------------------|------------------------------------------------------|
| `project_id`     | SLS project ID (i.e., the project name)              |
| `project_name`   | SLS project name                                     |
| `log_store_name` | Name of the created SLS logstore                     |
| `log_store_id`   | ID of the created SLS logstore (i.e., the logstore name) |

## Examples

For more usage scenarios, see the [`examples/`](./examples) directory:
- `create-project-and-logstore`: Create a new project and basic logstore  
- `create-logstore-with-indexes`: Create a logstore with full-text + field indexes in an existing project  
- `setup-full-log-collection`: Configure machine groups, Logtail, and end-to-end attachments  

## Notes

- ✅ This module **always operates on exactly one logstore**, specified via `log_store_name`; batch creation of multiple logstores is *not supported*.  
- ⚠️ After logstore creation, `shard_count` can only be *increased*, not decreased; `retention_period` can only be *extended*, not shortened.  
- ⚠️ `full_text_index` and `field_search_indexes` are applied *only upon initial logstore creation*. Subsequent modifications require manual re-indexing via the console or API — Terraform does *not* automatically update existing index schemas.  
- ⚠️ `logtail_attachments` requires *exact key-name matching* against `logtail_configs` and `machine_groups`; any typo will cause `precondition` validation failure.  
- ⚠️ When `append_meta = true`, system-injected metadata fields such as `__topic__`, `__source__`, and `__tag__:__hostname__` increase log volume and may impact query performance — enable only as needed.  
- 🌐 All resources are deployed within the Alibaba Cloud Stack region configured in the current Terraform context — cross-region deployments are *not supported*.