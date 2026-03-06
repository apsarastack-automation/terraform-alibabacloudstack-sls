# 阿里云日志服务（SLS）Terraform 模块

该模块用于在阿里云 Stack 上创建和管理日志服务（SLS）项目及核心日志采集分析资源，支持：
- **创建新的 SLS 项目** 并配置单个日志库
- **为现有 SLS 项目创建日志库**（通过指定已存在项目名）
- **配置日志库索引**（全文索引 + 字段索引）以支持高效搜索与分析
- **创建机器组**（Machine Group）用于统一管理日志采集源
- **定义 Logtail 配置** 并建立其与机器组的关联关系（Logtail Attachment）

> ⚠️ **重要说明**：本模块**仅支持创建单个日志库**（`log_store_name`），不支持批量创建多个日志库（即不支持 `log_stores` map 变量）。如需多日志库场景，请多次调用本模块。

## 功能特性

- ✅ 创建/复用 SLS 项目（Project）
- ✅ 创建单个日志库（Logstore），含分片、保留期、自动分裂等精细化配置
- ✅ 灵活配置日志库索引：支持全量文本索引（Full Text）与结构化字段索引（Field Search）
- ✅ 定义机器组（IP 或自定义标识类型），支持多组并存
- ✅ 声明式定义 Logtail 采集配置（File/Plugin 类型），并强制绑定至 LogService 输出
- ✅ 建立 Logtail 配置与机器组之间的关联关系（Attachment），支持多对多映射
- ✅ 内置完备校验：所有关键参数均含 `precondition` 校验，保障部署健壮性

## 使用方法

### 基础用法：创建新项目与日志库

```hcl
module "sls" {
  source = "<Module Path>"

  project_name     = "my-sls-project"
  description      = "由 Terraform 管理的日志服务项目"
  log_store_name   = "app-logs"
  shard_count      = 4
  retention_period = 90
}
```

### 进阶用法：为现有项目创建带索引的日志库

```hcl
module "sls" {
  source = "<Module Path>"

  project_name = "existing-project-name"  # 指向已存在的项目
  log_store_name = "audit-logs"

  # 全文索引配置
  full_text_index = {
    case_sensitive  = true
    include_chinese = true
    token           = " ,;=()\t\n"
  }

  # 字段索引配置
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

### 高级用法：完整日志采集链路（机器组 + Logtail + 关联）

```hcl
module "sls" {
  source = "<Module Path>"

  project_name = "prod-logs"
  log_store_name = "nginx-access"

  # 定义机器组：基于 IP 的服务器集群
  machine_groups = {
    nginx_servers = {
      identify_type = "ip"
      identify_list = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
      topic         = "nginx"
    }
  }

  # 定义 Logtail 配置：采集 Nginx 日志文件
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

  # 关联 Logtail 配置与机器组
  logtail_attachments = {
    attach_nginx_to_servers = {
      logtail_config_name = "nginx_access_config"
      machine_group_name  = "nginx_servers"
    }
  }
}
```

## 环境依赖

### Terraform Core

| 名称 | 版本 |
|------|------|
| Terraform | >= 1.5.6 |

### Provider

| 名称 | 版本 |
|------|------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## 模块变量

### 输入变量

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `project_name` | **SLS 项目名称。如果项目不存在，将自动创建。** | `string` | - | 是 |
| `description` | SLS 项目的简要描述（仅在创建新项目时生效） | `string` | `""` | 否 |
| `log_store_name` | **日志库（Logstore）名称。** | `string` | - | 是 |
| `shard_count` | 日志库初始分片数量（取值范围：1–100） | `number` | `2` | 否 |
| `retention_period` | 日志数据保留天数（取值范围：1–3650） | `number` | `30` | 否 |
| `auto_split` | 是否启用分片自动分裂 | `bool` | `false` | 否 |
| `max_split_shard_count` | 自动分裂允许的最大分片数（仅当 `auto_split = true` 时生效） | `number` | `64` | 否 |
| `append_meta` | 是否自动附加日志元数据（如 `__topic__`, `__source__` 等） | `bool` | `true` | 否 |
| `enable_web_tracking` | 是否启用 Web Tracking（前端日志采集） | `bool` | `false` | 否 |
| `full_text_index` | 全文索引配置对象（若为 `null` 则不创建全文索引） | `object({ case_sensitive = optional(bool), include_chinese = optional(bool), token = optional(string) })` | `null` | 否 |
| `field_search_indexes` | 字段索引配置列表（空列表则不创建字段索引） | `list(object({ name = string, type = optional(string), alias = optional(string), case_sensitive = optional(bool), include_chinese = optional(bool), token = optional(string), enable_analytics = optional(bool) }))` | `[]` | 否 |
| `machine_groups` | 机器组名称到配置的映射（键为组名，值为 `{ identify_type, identify_list, topic }` 对象） | `map(object({ identify_type = optional(string), identify_list = list(string), topic = optional(string) }))` | `{}` | 否 |
| `logtail_configs` | Logtail 配置名称到配置的映射（键为配置名，值为 `{ input_type, output_type, input_detail }` 对象） | `map(object({ input_type = string, output_type = string, input_detail = string }))` | `{}` | 否 |
| `logtail_attachments` | Logtail 关联名称到配置的映射（键为关联名，值为 `{ logtail_config_name, machine_group_name }` 对象） | `map(object({ logtail_config_name = string, machine_group_name = string }))` | `{}` | 否 |

> 💡 **关键约束说明**：
> - `shard_count` 和 `retention_period` 在创建后不可缩减。
> - `auto_split = true` 时，`max_split_shard_count` 必须 ≥ `shard_count`。
> - `logtail_configs` 中 `input_type` 仅支持 `"file"` 或 `"plugin"`；`output_type` 必须为 `"LogService"`。
> - `machine_groups` 中 `identify_type` 仅支持 `"ip"` 或 `"userdefined"`。
> - `logtail_attachments` 中引用的 `logtail_config_name` 和 `machine_group_name` 必须在对应变量中正确定义。

### 输出变量

| 名称 | 描述 |
|------|------|
| `project_id` | SLS 项目 ID（即项目名称） |
| `project_name` | SLS 项目名称 |
| `log_store_name` | 实际创建的 SLS 日志库名称 |
| `log_store_id` | 实际创建的 SLS 日志库 ID（即日志库名称） |

## 示例

更多使用场景请参见 [`examples/`](./examples) 目录：
- `create-project-and-logstore`：创建新项目与基础日志库
- `create-logstore-with-indexes`：为现有项目创建带全文+字段索引的日志库
- `setup-full-log-collection`：配置机器组、Logtail 及完整关联链路

## 注意事项

- ✅ 本模块**始终操作一个日志库**（由 `log_store_name` 指定），不支持批量创建多日志库。
- ⚠️ 日志库创建后，`shard_count` 只能增加，不能减少；`retention_period` 只能延长，不能缩短。
- ⚠️ `full_text_index` 和 `field_search_indexes` 仅在日志库创建后首次应用时生效；后续修改需手动在控制台或通过 API 触发重建索引（Terraform 不会自动更新已有索引结构）。
- ⚠️ `logtail_attachments` 依赖 `logtail_configs` 和 `machine_groups` 的键名严格匹配，拼写错误将导致 `precondition` 校验失败。
- ⚠️ `append_meta = true` 时，系统将自动注入 `__topic__`, `__source__`, `__tag__:__hostname__` 等元字段，影响日志体积与查询性能，请按需开启。
- 🌐 所有资源均部署在当前 Terraform 配置的 Alibaba Cloud Stack 区域内，不跨地域。