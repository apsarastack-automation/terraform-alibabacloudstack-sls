# 阿里云日志服务（SLS）Terraform 模块

该模块用于在阿里云 Stack 上创建 **SLS 项目、日志库及相关资源**。

## 功能特性

- 创建新的 SLS 项目
- 自动创建一个或多个日志库（通过 `log_stores` 定义）
- 可选：创建机器组用于日志采集
- 可选：创建 Logtail 配置和关联关系
- 可选：配置日志库索引用于搜索/分析

> ⚠️ **注意**：本模块**不支持**使用已有 SLS 项目（即不接受 `project_name`）。如需为现有项目创建日志库，请使用其他模块或直接调用 `alibabacloudstack_log_store` 资源。

## 使用方法

### 基础用法：创建 SLS 项目和日志库

``hcl
module "sls" {
  source = "<模块路径>"

  project_name = "my-sls-project"
  description  = "Terraform 管理的 SLS 项目"

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

### 高级用法：配置日志库索引

``hcl
module "sls" {
  source = "<模块路径>"

  project_name = "my-sls-project"
  description  = "Terraform 管理的 SLS 项目"

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

### 高级用法：配置机器组和 Logtail

```
module "sls" {
  source = "<模块路径>"

  project_name = "my-sls-project"
  description  = "Terraform 管理的 SLS 项目"

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

## 环境依赖

### Terraform Core

| 名称 | 版本 |
|------|------|
| Terraform | >= 1.5.6 |

### 提供商

| 名称 | 版本 |
|------|------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## 模块变量

### 输入变量

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `project_name` | SLS 项目名称 | `string` | - | 是 |
| `description` | SLS 项目描述 | `string` | `""` | 否 |
| `log_stores` | 日志库配置映射（格式：`{ store_name = { ...config } }`） | `map(object)` | `{}` | 否 |
| `machine_groups` | 机器组配置映射（格式：`{ group_name = { ...config } }`） | `map(object)` | `{}` | 否 |
| `logtail_configs` | Logtail 配置映射（格式：`{ config_name = { ...config } }`） | `map(object)` | `{}` | 否 |
| `logtail_attachments` | Logtail 关联配置映射（格式：`{ attach_name = { ...config } }`） | `map(object)` | `{}` | 否 |

#### 日志库对象结构

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `shard_count` | 分片数量 | `number` | - | 是 |
| `retention_period` | 数据保留时间（天，1-3650） | `number` | `30` | 否 |
| `auto_split` | 是否自动分裂分片 | `bool` | `false` | 否 |
| `max_split_shard_count` | 自动分裂的最大分片数 | `number` | `64` | 否 |
| `append_meta` | 是否自动附加日志元信息 | `bool` | `true` | 否 |
| `enable_web_tracking` | 是否启用 Web Tracking | `bool` | `false` | 否 |
| `full_text_index` | 全文索引配置（见下文） | `object` | `null` | 否 |
| `field_search_indexes` | 字段搜索索引配置列表（见下文） | `list` | `[]` | 否 |

#### 全文索引对象结构

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `case_sensitive` | 是否区分大小写 | `bool` | `false` | 否 |
| `include_chinese` | 是否包含中文 | `bool` | `false` | 否 |
| `token` | 分词字符串 | `string` | `""` | 否 |

#### 字段搜索索引对象结构

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `name` | 字段名称 | `string` | - | 是 |
| `type` | 字段类型（long, text, double, json） | `string` | `"long"` | 否 |
| `alias` | 字段别名 | `string` | `""` | 否 |
| `case_sensitive` | 是否区分大小写 | `bool` | `false` | 否 |
| `include_chinese` | 是否包含中文 | `bool` | `false` | 否 |
| `token` | 分词字符串 | `string` | `""` | 否 |
| `enable_analytics` | 是否启用字段分析 | `bool` | `true` | 否 |

### 输出变量

| 名称 | 描述 |
|------|------|
| `project_name` | 创建的 SLS 项目名称 |
| `project_id` | 创建的 SLS 项目 ID |
| `log_store_names` | 创建的日志库名称列表 |

## 示例

更多使用场景请参见 [`examples/`](./examples) 目录：
- `create-sls-project-with-logstore` - 创建新的 SLS 项目及日志库
- `create-logstore-for-existing-project` - 为现有 SLS 项目创建日志库
- `create-machine-group-for-existing-project` - 为现有 SLS 项目创建机器组
- `create-logtail-config-for-existing-logstore` - 为现有日志库创建 Logtail 配置
- `create-logstore-index-for-existing-logstore` - 为现有日志库创建索引
- `complete-log-collection-setup` - 完整的日志采集方案，包含所有 SLS 资源

## 注意事项

- 本模块**总是创建新的 SLS 项目**，不支持操作已有实例。
- 日志库的分片数量在创建后**不能减少**。
- 日志库索引配置在创建后**不能修改**，除非重新创建索引。
