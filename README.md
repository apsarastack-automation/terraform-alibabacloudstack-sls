# Alibaba Cloud Log Service (SLS) Terraform Module

This module creates **SLS projects, log stores, and related resources** on Alibaba Cloud Stack.

## Features

- Creates a new SLS project  
- Automatically creates one or more log stores (defined via `log_stores`)
- Optional: Creates machine groups for log collection
- Optional: Creates logtail configurations and attachments
- Optional: Configures log store indexes for search/analytics

> ⚠️ **Note**: This module **does not support** using an existing SLS project (i.e., it does *not* accept a `project_name`). To create log stores for an existing project, use another module or directly invoke the `alibabacloudstack_log_store` resource.

## Usage

### Basic Usage: Create SLS Project and Log Stores

```hcl
module "sls" {
  source = "<Module Path>"

  project_name = "my-sls-project"
  description  = "Terraform managed SLS project"

  log_stores = {
    app_log = {
      shard_count           = 3
      retention_period      = 30
      auto_split            = true
      max_split_shard_count = 60
    }
    system_log = {
      shard_count      = 2
      retention_period = 7
    }
  }
}
```

### Advanced Usage: With Log Store Index

```hcl
module "sls" {
  source = "<Module Path>"

  project_name = "my-sls-project"
  description  = "Terraform managed SLS project"

  log_stores = {
    app_log = {
      shard_count           = 3
      retention_period      = 30
      auto_split            = true
      max_split_shard_count = 60
      
      full_text_index = {
        case_sensitive = true
        token          = " #$%^*\r\n\t"
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
  }
}
```

### Advanced Usage: With Machine Group and Logtail Config

```hcl
module "sls" {
  source = "<Module Path>"

  project_name = "my-sls-project"
  description  = "Terraform managed SLS project"

  log_stores = {
    app_log = {
      shard_count = 2
    }
  }

  machine_groups = {
    web_servers = {
      identify_type = "ip"
      identify_list = ["10.0.0.1", "10.0.0.2"]
      topic         = "web"
    }
  }

  logtail_configs = {
    nginx_access = {
      logstore    = "app_log"
      input_type  = "file"
      output_type = "LogService"
      log_sample  = "127.0.0.1 - - [10/Oct/2023..."
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

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.5.6  |

### Provider

| Name              | Version                |
|-------------------|------------------------|
| alibabacloudstack | >= 3.18.24, < 3.19.0   |

## Module Variables

### Input Variables

| Name                  | Description                                                                                     | Type              | Default | Required |
|-----------------------|-------------------------------------------------------------------------------------------------|-------------------|---------|----------|
| `project_name`        | SLS project name                                                                                | `string`          | —       | Yes      |
| `description`         | SLS project description                                                                         | `string`          | `""`    | No       |
| `log_stores`          | Map of log store configurations (format: `{ store_name = { ...config } }`)                      | `map(object)`     | `{}`    | No       |
| `machine_groups`      | Map of machine group configurations (format: `{ group_name = { ...config } }`)                  | `map(object)`     | `{}`    | No       |
| `logtail_configs`     | Map of logtail config configurations (format: `{ config_name = { ...config } }`)                | `map(object)`     | `{}`    | No       |
| `logtail_attachments` | Map of logtail attachment configurations (format: `{ attach_name = { ...config } }`)            | `map(object)`     | `{}`    | No       |

#### Log Store Object Schema

| Name                  | Description                                                            | Type     | Default | Required |
|-----------------------|------------------------------------------------------------------------|----------|---------|----------|
| `shard_count`         | Number of shards                                                       | `number` | —       | Yes      |
| `retention_period`    | Data retention time in days (1-3650)                                   | `number` | `30`    | No       |
| `auto_split`          | Whether to automatically split shards                                  | `bool`   | `false` | No       |
| `max_split_shard_count` | Maximum number of shards for auto split                              | `number` | `64`    | No       |
| `append_meta`         | Whether to append log meta automatically                               | `bool`   | `true`  | No       |
| `enable_web_tracking` | Whether to enable Web Tracking                                         | `bool`   | `false` | No       |
| `full_text_index`     | Full text index configuration (see below)                              | `object` | `null`  | No       |
| `field_search_indexes`| List of field search index configurations (see below)                  | `list`   | `[]`    | No       |

#### Full Text Index Object Schema

| Name              | Description                               | Type     | Default | Required |
|-------------------|-------------------------------------------|----------|---------|----------|
| `case_sensitive`  | Whether case sensitive                    | `bool`   | `false` | No       |
| `include_chinese` | Whether includes chinese                  | `bool`   | `false` | No       |
| `token`           | Token string for splitting words          | `string` | `""`    | No       |

#### Field Search Index Object Schema

| Name               | Description                                    | Type     | Default  | Required |
|--------------------|------------------------------------------------|----------|----------|----------|
| `name`             | Field name                                     | `string` | —        | Yes      |
| `type`             | Field type (long, text, double, json)          | `string` | `"long"` | No       |
| `alias`            | Field alias                                    | `string` | `""`     | No       |
| `case_sensitive`   | Whether case sensitive                         | `bool`   | `false`  | No       |
| `include_chinese`  | Whether includes chinese                       | `bool`   | `false`  | No       |
| `token`            | Token string for splitting words               | `string` | `""`     | No       |
| `enable_analytics` | Whether to enable field analytics              | `bool`   | `true`   | No       |

### Output Variables

| Name             | Description                                      |
|------------------|--------------------------------------------------|
| `project_name`   | Name of the created SLS project                  |
| `project_id`     | ID of the created SLS project                    |
| `log_store_names`| List of created log store names                  |

## Examples

For more usage scenarios, see the [`examples/`](./examples) directory:  
- `create-sls-project-with-logstore` - Create a new SLS project with log stores
- `create-logstore-for-existing-project` - Create log stores for an existing SLS project
- `create-machine-group-for-existing-project` - Create machine groups for an existing SLS project
- `create-logtail-config-for-existing-logstore` - Create Logtail configs for existing log stores
- `create-logstore-index-for-existing-logstore` - Create indexes for existing log stores
- `complete-log-collection-setup` - Complete log collection solution with all SLS resources

## Notes

- This module **always creates a new SLS project** and does *not* support operating on an existing one.
- A log store's shard count **cannot be decreased** after creation.
- Log store index configuration **cannot be modified** after creation without recreating the index.
