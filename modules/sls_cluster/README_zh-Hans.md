# 阿里云日志服务（SLS）Terraform 模块

该模块用于在阿里云 Stack 上管理日志服务（SLS）项目及相关资源，支持：
- **创建新的 SLS 项目** 并配置日志库
- **为现有的 SLS 项目创建日志库**
- **配置机器组** 用于日志采集
- **创建 Logtail 配置** 和关联关系
- **设置日志库索引** 用于搜索和分析

## 支持资源

* [alibabacloudstack_log_project](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_project)
* [alibabacloudstack_log_store](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_store)
* [alibabacloudstack_log_store_index](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_store_index)
* [alibabacloudstack_log_machine_group](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_machine_group)
* [alibabacloudstack_logtail_config](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/logtail_config)
* [alibabacloudstack_logtail_attachment](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/logtail_attachment)

## 使用方法

### 场景 1：创建新的 SLS 项目和日志库

```hcl
module "sls" {
  source = "./terraform-alibabacloudstack-sls"

  project_name = "my-sls-project"
  description  = "Terraform 管理的 SLS 项目"
  
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

### 场景 2：为现有 SLS 项目创建日志库

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

### 场景 3：创建带索引的 SLS 项目

```hcl
module "sls" {
  source = "./terraform-alibabacloudstack-sls"

  project_name = "my-sls-project"
  description  = "Terraform 管理的 SLS 项目"
  
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

### 场景 4：创建机器组和 Logtail 配置

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

> ⚠️ **关键约束**：
> - `project_name` 始终需要指定要操作的项目。
> - 日志库分片数量在创建后不能减少。

## 要求

| 名称 | 版本 |
|------|------|
| terraform | >= 1.5.6 |

## 提供商

| 名称 | 版本 |
|------|------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## 输入变量

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| **project_name** | **SLS 项目名称。如果项目不存在，将会创建。** | `string` | `""` | 是 |
| description | SLS 项目的简要描述（仅在创建新项目时生效） | `string` | `""` | 否 |
| log_stores | 日志库名称到其配置的映射 | `map(object)` | `{}` | 否 |
| machine_groups | 机器组名称到其配置的映射 | `map(object)` | `{}` | 否 |
| logtail_configs | Logtail 配置名称到其配置的映射 | `map(object)` | `{}` | 否 |
| logtail_attachments | Logtail 关联名称到其配置的映射 | `map(object)` | `{}` | 否 |

## 输出变量

| 名称 | 描述 |
|------|------|
| project_id | SLS 项目 ID |
| project_name | SLS 项目名称 |
| log_store_names | 实际创建的 SLS 日志库名称列表 |

## 注意事项

* 创建带索引配置的日志库时，索引会在日志库就绪后自动创建。
* 机器组用于通过 Logtail 管理 ECS 实例进行日志采集。

## 提交问题

如果您在使用此模块时遇到任何问题，请提交 [provider issue](https://github.com/aliyun/terraform-provider-alibabacloudstack/issues/new) 并告知我们。

**注意：** 不建议在此仓库上提交 issue。

## 作者

由阿里云 Terraform 团队创建和维护

## 许可证

MIT 许可证。详情请参见 LICENSE。

## 参考

* [Terraform-Provider-Alibabacloudstack Github](https://github.com/aliyun/terraform-provider-alibabacloudstack)
* [Terraform-Provider-Alibabacloudstack Release](https://registry.terraform.io/providers/aliyun/alibabacloudstack)
* [Terraform-Provider-Alibabacloudstack 文档](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs)
