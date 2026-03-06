# Alibaba Cloud Log Service (SLS) Terraform Module

This module manages Alibaba Cloud Log Service (SLS) projects and related resources on Alibaba Cloud Stack, supporting:
- **Creating a new SLS project** and configuring log stores
- **Creating log stores for an existing SLS project**
- **Configuring machine groups** for log collection
- **Creating Logtail configurations** and attachments
- **Setting up log store indexes** for search and analytics

## Supported Resources

* [alibabacloudstack_log_project](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_project)
* [alibabacloudstack_log_store](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_store)
* [alibabacloudstack_log_store_index](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_store_index)
* [alibabacloudstack_log_machine_group](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_machine_group)
* [alibabacloudstack_logtail_config](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/logtail_config)
* [alibabacloudstack_logtail_attachment](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/logtail_attachment)

## Usage Examples

### Scenario 1: Create a new SLS project and log stores

```hcl
module "sls" {
  source = "./terraform-alibabacloudstack-sls"

  project_name = "my-sls-project"
  description  = "Terraform managed SLS project"
  
  log_stores = {
    app_log = {
      shard_count      = 3
      retention_period = 30
    }
    system_log = {
      shard_count      = 2
      retention_period = 7
    }
  }
}
```

### Scenario 2: Create log stores for an existing SLS project

```hcl
module "sls" {
  source = "./terraform-alibabacloudstack-sls"

  project_name = "existing-sls-project"
  
  log_stores = {
    new_logstore = {
      shard_count = 2
    }
  }
}
```

### Scenario 3: Create SLS project with log store index

```hcl
module "sls" {
  source = "./terraform-alibabacloudstack-sls"

  project_name = "my-sls-project"
  description  = "Terraform managed SLS project"
  
  log_stores = {
    app_log = {
      shard_count = 3
      full_text_index = {
        case_sensitive = true
        token          = " #$%^*\r\n\t"
      }
      field_search_indexes = [
        {
          name             = "level"
          type             = "text"
          enable_analytics = true
        }
      ]
    }
  }
}
```

### Scenario 4: Create with machine group and Logtail config

```hcl
module "sls" {
  source = "./terraform-alibabacloudstack-sls"

  project_name = "my-sls-project"
  
  log_stores = {
    app_log = {
      shard_count = 2
    }
  }

  machine_groups = {
    web_servers = {
      identify_type = "ip"
      identify_list = ["10.0.0.1", "10.0.0.2"]
    }
  }

  logtail_configs = {
    nginx_access = {
      logstore     = "app_log"
      input_type   = "file"
      output_type  = "LogService"
      input_detail = file("config.json")
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

> ⚠️ **Key Constraints**:
> - `project_name` is always required to specify the project to work with.
> - Log store shard count cannot be decreased after creation.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.6 |

## Providers

| Name | Version |
|------|---------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| **project_name** | **Name of the SLS project. If the project doesn't exist, it will be created.** | `string` | `""` | Yes |
| description | Brief description of the SLS project (applies only when creating a new project) | `string` | `""` | No |
| log_stores | Map of log store names to their configurations | `map(object)` | `{}` | No |
| machine_groups | Map of machine group names to their configurations | `map(object)` | `{}` | No |
| logtail_configs | Map of logtail config names to their configurations | `map(object)` | `{}` | No |
| logtail_attachments | Map of logtail attachment names to their configurations | `map(object)` | `{}` | No |

## Output Values

| Name | Description |
|------|-------------|
| project_id | ID of the SLS project |
| project_name | Name of the SLS project |
| log_store_names | List of SLS log store names that were actually created |

## Notes

* When creating a log store with index configuration, the index will be automatically created after the log store is ready.
* Machine groups are used to manage ECS instances for log collection via Logtail.

## Reporting Issues

If you encounter any issues while using this module, please open an issue in the [provider repository](https://github.com/aliyun/terraform-provider-alibabacloudstack/issues/new).

> **Note**: Please do **not** open issues in this module's repository.

## Authors

Created and maintained by the Alibaba Cloud Terraform Team.

## License

MIT License. See LICENSE for details.

## References

* [Terraform Provider for Alibaba Cloud Stack (GitHub)](https://github.com/aliyun/terraform-provider-alibabacloudstack)
* [Terraform Provider Registry](https://registry.terraform.io/providers/aliyun/alibabacloudstack)
* [Provider Documentation](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs)
