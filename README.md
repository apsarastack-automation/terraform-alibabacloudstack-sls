# Alibaba Cloud Log Service (SLS) Terraform Module

This module is used to create **SLS projects, individual logstores, and related resources** on Alibaba Cloud Stack.

## Features

- Creates a new SLS project (reuses the project if it already exists).
- Automatically creates one logstore (named via `log_store_name`).
- Optional: Configures basic logstore parameters such as shard count, retention period, and automatic shard splitting.
- Optional: Configures full-text indexing and field-level search indexing for the logstore.
- Optional: Creates machine groups for log collection.
- Optional: Creates Logtail configurations and associates them with machine groups.

> ⚠️ **Note**: This module **does not support** creating multiple logstores simultaneously (i.e., it does not accept a `log_stores` map structure). To manage multiple logstores, invoke this module separately for each logstore or use a higher-level wrapper module.

## Usage

### Basic Usage: Create an SLS Project and a Single Logstore

```hcl
module "sls" {
  source = "<module-path>"

  project_name     = "my-sls-project"
  description      = "SLS project managed by Terraform"
  log_store_name   = "app_log"
  shard_count      = 3
  retention_period = 30
}
```

### Advanced Usage: Configure Logstore Indexing

```hcl
module "sls" {
  source = "<module-path>"

  project_name     = "my-sls-project"
  description      = "SLS project managed by Terraform"
  log_store_name   = "app_log"
  shard_count      = 3
  retention_period = 30

  full_text_index = {
    case_sensitive  = true
    include_chinese = true
    token           = " #$%^*\r\n\t"
  }

  field_search_indexes = [
    {
      name             = "level"
      type             = "text"
      enable_analytics = true
    },
    {
      name             = "request_id"
      type             = "text"
      enable_analytics = true
    }
  ]
}
```

### Advanced Usage: Configure Machine Groups and Logtail

```hcl
module "sls" {
  source = "<module-path>"

  project_name     = "my-sls-project"
  description      = "SLS project managed by Terraform"
  log_store_name   = "app_log"
  shard_count      = 2

  machine_groups = {
    web_servers = {
      identify_type = "ip"
      identify_list = ["10.0.0.1", "10.0.0.2"]
      topic         = "web"
    }
  }

  logtail_configs = {
    nginx_access = {
      input_type   = "file"
      output_type  = "LogService"
      input_detail = jsonencode({
        logPath       = "/var/log/nginx"
        filePattern   = "access.log"
        logType       = "nginx_log"
        topicFormat   = "default"
        discardUnmatch = false
        enableRawLog  = true
        fileEncoding  = "utf8"
        maxDepth      = 10
      })
    }
  }

  logtail_attachments = {
    nginx_to_web = {
      logtail_config_name = "nginx_access"
      machine_group_name  = "web_servers"
    }
  }
}
```

## Environment Dependencies

### Terraform Core

| Name      | Version     |
|-----------|-------------|
| Terraform | >= 1.5.6    |

### Providers

| Name              | Version               |
|-------------------|-----------------------|
| alibabacloudstack | >= 3.18.24, < 3.19.0  |

## Module Variables

### Input Variables

| Name                    | Description                                                                                                             | Type     | Default | Required |
|-------------------------|-------------------------------------------------------------------------------------------------------------------------|----------|---------|----------|
| `project_name`          | **Name of the SLS project. If the project does not exist, it will be created; if it already exists, it will be reused.** | `string` | —       | Yes      |
| `description`           | Brief description of the SLS project (takes effect only when creating a new project)                                     | `string` | `""`    | No       |
| `log_store_name`        | Name of the logstore                                                                                                    | `string` | `""`    | No       |
| `shard_count`           | Number of shards for the logstore (1–100)                                                                               | `number` | `2`     | No       |
| `retention_period`      | Data retention period (in days); valid range: 1–3650                                                                    | `number` | `30`    | No       |
| `auto_split`            | Whether to enable automatic shard splitting                                                                             | `bool`   | `false` | No       |
| `max_split_shard_count` | Maximum number of shards allowed for automatic splitting (effective only when `auto_split = true`)                     | `number` | `64`    | No       |
| `append_meta`           | Whether to automatically append log metadata (e.g., timestamps, client IP addresses, etc.)                              | `bool`   | `true`  | No       |
| `enable_web_tracking`   | Whether to enable Web Tracking (for frontend log collection)                                                            | `bool`   | `false` | No       |
| `full_text_index`       | Full-text index configuration object (see structure details below)                                                      | `object` | `null`  | No       |
| `field_search_indexes`  | List of field-level search index configurations (see structure details below)                                           | `list(object)` | `[]` | No       |
| `machine_groups`        | Map from machine group names to their configurations (see structure details below)                                      | `map(object)` | `{}` | No       |
| `logtail_configs`       | Map from Logtail configuration names to their configurations (see structure details below)                                | `map(object)` | `{}` | No       |
| `logtail_attachments`   | Map from Logtail attachment names to their configurations (see structure details below)                                   | `map(object)` | `{}` | No       |

#### Full-Text Index Object Structure (`full_text_index`)

| Name              | Description                                                                                      | Type     | Default | Required |
|-------------------|--------------------------------------------------------------------------------------------------|----------|---------|----------|
| `case_sensitive`  | Whether case sensitivity is enabled                                                              | `bool`   | `false` | No       |
| `include_chinese` | Whether Chinese text segmentation is supported                                                   | `bool`   | `false` | No       |
| `token`           | Custom tokenization string (supports spaces, tabs, line breaks, and special characters)         | `string` | `""`    | No       |

#### Field Search Index Object Structure (each element in `field_search_indexes` list)

| Name                | Description                                                                                                                                                             | Type     | Default | Required |
|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|----------|
| `name`              | Field name (must exactly match the field name in log content)                                                                                                         | `string` | —       | Yes      |
| `type`              | Field data type (valid values: `"long"`, `"text"`, `"double"`, `"json"`)                                                                                              | `string` | `"long"`| No       |
| `alias`             | Field alias (used to simplify field names during queries)                                                                                                             | `string` | `null`  | No       |
| `case_sensitive`    | Whether case sensitivity is enabled (applies only to `"text"` fields)                                                                                                 | `bool`   | `false` | No       |
| `include_chinese`   | Whether Chinese text segmentation is supported (applies only to `"text"` fields)                                                                                      | `bool`   | `false` | No       |
| `token`             | Custom tokenizer (applies only to `"text"` fields)                                                                                                                    | `string` | `null`  | No       |
| `enable_analytics`  | Whether to enable field analytics (enables statistical queries such as `count`, `avg`, etc.)                                                                           | `bool`   | `true`  | No       |

#### Machine Group Object Structure (each value in `machine_groups` map)

| Name              | Description                                                                                                                                  | Type     | Default | Required |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|----------|
| `identify_type`   | Identification method (`"ip"` for IP-based identification; `"userdefined"` for custom identifier-based identification)                      | `string` | `"ip"`  | No       |
| `identify_list`   | List of identifiers (e.g., IP addresses or user-defined IDs)                                                                                | `list(string)` | —       | Yes      |
| `topic`           | Topic (used for log routing and filtering)                                                                                                  | `string` | `""`    | No       |

#### Logtail Configuration Object Structure (each value in `logtail_configs` map)

| Name            | Description                                                                                                                | Type     | Default | Required |
|-----------------|----------------------------------------------------------------------------------------------------------------------------|----------|---------|----------|
| `input_type`    | Input type (must be `"file"` or `"plugin"`)                                                                                 | `string` | —       | Yes      |
| `output_type`   | Output type (must be `"LogService"`)                                                                                        | `string` | —       | Yes      |
| `input_detail`  | Detailed input configuration (JSON string; format depends on `input_type`)                                                  | `string` | —       | Yes      |

#### Logtail Attachment Object Structure (each value in `logtail_attachments` map)

| Name                   | Description                                                                                                                         | Type     | Default | Required |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------|----------|---------|----------|
| `logtail_config_name`  | Name of the pre-defined Logtail configuration (must exist in `logtail_configs`)                                                     | `string` | —       | Yes      |
| `machine_group_name`   | Name of the pre-defined machine group (must exist in `machine_groups`)                                                              | `string` | —       | Yes      |

### Output Variables

| Name             | Description                                                                                          |
|------------------|------------------------------------------------------------------------------------------------------|
| `project_id`     | SLS project ID (i.e., the project name; SLS projects do not have a separate ID field)                |
| `project_name`   | SLS project name                                                                                     |
| `log_store_name` | Name of the created SLS logstore                                                                     |
| `log_store_id`   | SLS logstore ID (i.e., the logstore name; SLS logstores do not have a separate ID field)            |

## Examples

For more usage scenarios, refer to the [`examples/`](./examples) directory:
- `create-sls-project-with-logstore` — Creates a new project and a logstore  
- `create-logstore-for-existing-project` — Creates a logstore within an existing project  
- `create-logstore-with-indexes` — Creates a logstore with full-text and field-level indexes  
- `setup-log-collection` — Complete log collection setup (including machine groups + Logtail configuration + associations)

## Notes

- This module **supports reusing existing SLS projects** (simply specify `project_name`); it does *not* mandate creation of a new project.
- A logstore’s `shard_count` **cannot be reduced** after creation. If `auto_split` is enabled, `max_split_shard_count` must be ≥ `shard_count`.
- `retention_period` is strictly constrained to the range **1–3650 days**; values outside this range will cause pre-check validation failures.
- `full_text_index` and `field_search_indexes` take effect **only upon initial logstore creation**. To update indexes, you must delete and recreate the logstore (SLS does not support hot index updates).
- The `input_detail` field in `logtail_configs` must be a valid JSON string; we recommend using the `jsonencode()` function to generate it and ensure correct formatting.
- `machine_groups.identify_list` must contain **at least one valid identifier** (IP address or custom ID); otherwise, deployment will fail.