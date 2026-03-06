# 阿里云日志服务（SLS）Terraform 模块

该模块用于在阿里云 Stack 上创建 **SLS 项目、单个日志库及相关资源**。

## 功能特性

- 创建新的 SLS 项目（如项目已存在，则复用）
- 自动创建一个日志库（通过 `log_store_name` 指定）
- 可选：配置日志库分片、保留周期、自动分裂等基础参数
- 可选：配置日志库全文索引和字段搜索索引
- 可选：创建机器组用于日志采集
- 可选：创建 Logtail 配置及与机器组的关联关系

> ⚠️ **注意**：本模块**不支持**同时创建多个日志库（即不支持 `log_stores` 映射结构）。如需管理多个日志库，请为每个日志库单独调用本模块或使用更高级的封装模块。

## 使用方法

### 基础用法：创建 SLS 项目和单个日志库

```hcl
module "sls" {
  source = "<模块路径>"

  project_name     = "my-sls-project"
  description      = "Terraform 管理的 SLS 项目"
  log_store_name   = "app_log"
  shard_count      = 3
  retention_period = 30
}
```

### 高级用法：配置日志库索引

```hcl
module "sls" {
  source = "<模块路径>"

  project_name     = "my-sls-project"
  description      = "Terraform 管理的 SLS 项目"
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

### 高级用法：配置机器组和 Logtail

```hcl
module "sls" {
  source = "<模块路径>"

  project_name     = "my-sls-project"
  description      = "Terraform 管理的 SLS 项目"
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
| `project_name` | **SLS 项目名称。如果项目不存在，将会创建；如果已存在，则复用。** | `string` | - | 是 |
| `description` | SLS 项目的简要描述（仅在创建新项目时生效） | `string` | `""` | 否 |
| `log_store_name` | 日志库名称 | `string` | `""` | 否 |
| `shard_count` | 日志库分片数量（1–100） | `number` | `2` | 否 |
| `retention_period` | 数据保留时间（天），取值范围：1–3650 | `number` | `30` | 否 |
| `auto_split` | 是否启用分片自动分裂 | `bool` | `false` | 否 |
| `max_split_shard_count` | 自动分裂允许的最大分片数（当 `auto_split = true` 时生效） | `number` | `64` | 否 |
| `append_meta` | 是否自动附加日志元信息（如时间戳、客户端IP等） | `bool` | `true` | 否 |
| `enable_web_tracking` | 是否启用 Web Tracking（用于前端日志采集） | `bool` | `false` | 否 |
| `full_text_index` | 全文索引配置对象（详见下方结构说明） | `object` | `null` | 否 |
| `field_search_indexes` | 字段搜索索引配置列表（详见下方结构说明） | `list(object)` | `[]` | 否 |
| `machine_groups` | 机器组名称到其配置的映射（详见下方结构说明） | `map(object)` | `{}` | 否 |
| `logtail_configs` | Logtail 配置名称到其配置的映射（详见下方结构说明） | `map(object)` | `{}` | 否 |
| `logtail_attachments` | Logtail 关联名称到其配置的映射（详见下方结构说明） | `map(object)` | `{}` | 否 |

#### 全文索引对象结构（`full_text_index`）

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `case_sensitive` | 是否区分大小写 | `bool` | `false` | 否 |
| `include_chinese` | 是否支持中文分词 | `bool` | `false` | 否 |
| `token` | 自定义分词符字符串（支持空格、制表符、换行符及特殊字符） | `string` | `""` | 否 |

#### 字段搜索索引对象结构（`field_search_indexes` 列表中每个元素）

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `name` | 字段名称（必须与日志内容中的字段名一致） | `string` | - | 是 |
| `type` | 字段数据类型（可选值：`"long"`、`"text"`、`"double"`、`"json"`） | `string` | `"long"` | 否 |
| `alias` | 字段别名（用于查询时简化字段名） | `string` | `null` | 否 |
| `case_sensitive` | 是否区分大小写（仅对 `text` 类型有效） | `bool` | `false` | 否 |
| `include_chinese` | 是否支持中文分词（仅对 `text` 类型有效） | `bool` | `false` | 否 |
| `token` | 自定义分词符（仅对 `text` 类型有效） | `string` | `null` | 否 |
| `enable_analytics` | 是否启用字段分析（开启后支持统计类查询，如 `count`、`avg`） | `bool` | `true` | 否 |

#### 机器组对象结构（`machine_groups` 映射中每个值）

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `identify_type` | 识别方式（`"ip"` 表示按 IP 识别，`"userdefined"` 表示按自定义标识识别） | `string` | `"ip"` | 否 |
| `identify_list` | 识别标识列表（如 IP 地址或用户自定义 ID） | `list(string)` | - | 是 |
| `topic` | 主题（可用于日志路由和过滤） | `string` | `""` | 否 |

#### Logtail 配置对象结构（`logtail_configs` 映射中每个值）

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `input_type` | 输入类型（必须为 `"file"` 或 `"plugin"`） | `string` | - | 是 |
| `output_type` | 输出类型（必须为 `"LogService"`） | `string` | - | 是 |
| `input_detail` | 输入配置详情（JSON 字符串，格式取决于 `input_type`） | `string` | - | 是 |

#### Logtail 关联对象结构（`logtail_attachments` 映射中每个值）

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `logtail_config_name` | 已定义的 Logtail 配置名称（必须存在于 `logtail_configs` 中） | `string` | - | 是 |
| `machine_group_name` | 已定义的机器组名称（必须存在于 `machine_groups` 中） | `string` | - | 是 |

### 输出变量

| 名称 | 描述 |
|------|------|
| `project_id` | SLS 项目 ID（即项目名称，SLS 项目无独立 ID 字段） |
| `project_name` | SLS 项目名称 |
| `log_store_name` | 创建的 SLS 日志库名称 |
| `log_store_id` | SLS 日志库 ID（即日志库名称，SLS 日志库无独立 ID 字段） |

## 示例

更多使用场景请参见 [`examples/`](./examples) 目录：
- `create-sls-project-with-logstore` — 创建新项目及日志库
- `create-logstore-for-existing-project` — 为现有项目创建日志库
- `create-logstore-with-indexes` — 创建带全文及字段索引的日志库
- `setup-log-collection` — 完整日志采集方案（含机器组 + Logtail 配置 + 关联）

## 注意事项

- 本模块**支持复用已有 SLS 项目**（通过指定 `project_name` 即可），并非强制创建新项目。
- 日志库的 `shard_count` 在创建后**不可减少**；若启用 `auto_split`，则 `max_split_shard_count` 必须 ≥ `shard_count`。
- `retention_period` 取值范围严格限制为 **1–3650 天**，超出将触发预检失败。
- `full_text_index` 和 `field_search_indexes` 仅在首次创建日志库时生效；如需更新索引，需先删除再重建日志库（SLS 不支持索引热更新）。
- `logtail_configs` 中的 `input_detail` 必须是合法 JSON 字符串；建议使用 `jsonencode()` 函数生成以确保格式正确。
- `machine_groups.identify_list` 至少需包含一个有效标识（IP 或自定义 ID），否则部署失败。