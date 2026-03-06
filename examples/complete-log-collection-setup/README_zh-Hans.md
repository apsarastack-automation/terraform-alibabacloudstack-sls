# 完整日志采集配置

此 Terraform 示例用于**创建完整的日志采集方案**，使用阿里云日志服务（SLS）。  
包含 SLS 项目、带索引的日志库、机器组、Logtail 配置及关联关系—**一站式日志采集和分析解决方案**。

## 使用方法

1. 配置变量（通过 `terraform.tfvars` 或命令行）：
   ```hcl
   project_name   = "my-complete-sls"
   description    = "完整日志采集配置"
   log_store_name = "app-logs"
   shard_count    = 2
   retention_period = 30
   
   full_text_index = {
     case_sensitive = false
     token          = " #$%^*\r\n\t"
   }
   
   field_search_indexes = [
     {
       name             = "remote_addr"
       type             = "text"
       enable_analytics = true
     },
     {
       name             = "status"
       type             = "long"
       enable_analytics = true
     },
     {
       name             = "request_time"
       type             = "double"
       enable_analytics = true
     }
   ]

   machine_groups = {
     web_servers = {
       identify_type = "ip"
       identify_list = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]
       topic         = "nginx"
     }
   }

   logtail_configs = {
     nginx_access_log = {
       input_type  = "file"
       output_type = "LogService"
       input_detail = jsonencode({
         logPath        = "/var/log/nginx"
         filePattern    = "access.log"
         logType        = "nginx_log"
         topicFormat    = "default"
         discardUnmatch = false
         enableRawLog   = false
         fileEncoding   = "utf8"
         maxDepth       = 10
       })
     }
   }

   logtail_attachments = {
     nginx_to_web = {
       logtail_config_name = "nginx_access_log"
       machine_group_name  = "web_servers"
     }
   }
   ```

2. 执行以下命令：
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. 清理所有资源：
   ```bash
   terraform destroy
   ```

## 要求

| 名称 | 版本 |
|------|------|
| Terraform | >= 1.5.6 |

## 提供商

| 名称 | 版本 |
|------|------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## 模块依赖

| 模块名称 | 来源路径 |
|----------|----------|
| `sls_complete` | `../../modules/sls_cluster` |

## 输入变量

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| `project_name` | SLS 项目名称 | `string` | - | 是 |
| `description` | SLS 项目描述 | `string` | 见描述 | 否 |
| `log_store_name` | 日志库名称 | `string` | "app-logs" | 否 |
| `shard_count` | 分片数量 | `number` | 2 | 否 |
| `retention_period` | 数据保留天数 | `number` | 30 | 否 |
| `auto_split` | 启用自动分裂 | `bool` | true | 否 |
| `max_split_shard_count` | 最大分裂分片数 | `number` | 64 | 否 |
| `full_text_index` | 全文索引配置 | `object` | null | 否 |
| `field_search_indexes` | 字段搜索索引配置 | `list(object)` | [] | 否 |
| `machine_groups` | 机器组配置映射 | `map(object)` | `{}` | 否 |
| `logtail_configs` | Logtail 配置映射 | `map(object)` | `{}` | 否 |
| `logtail_attachments` | Logtail 关联配置映射 | `map(object)` | `{}` | 否 |

## 输出变量

| 名称 | 描述 |
|------|------|
| `project_id` | 创建的 SLS 项目 ID |
| `project_name` | 创建的 SLS 项目名称 |
| `log_store_name` | 创建的日志库名称 |
| `log_store_id` | 创建的日志库 ID |

## 架构说明

此示例设置以下 SLS 资源：

1. **SLS 项目** - 所有日志资源的容器
2. **日志库** - 日志的存储单元
3. **日志库索引** - 启用日志数据的搜索和分析功能
4. **机器组** - 定义哪些服务器将采集日志
5. **Logtail 配置** - 定义如何解析和采集日志
6. **Logtail 关联** - 将配置连接到机器组

## 注意事项

- 如果指定的 `project_name` 已存在，模块将使用现有项目而不是创建新的。
- 机器组 IP 应替换为您的实际服务器 IP。
- Logtail 的 `input_detail` 格式因 `logType` 而异。详情请参考 SLS 文档。
- 执行 `terraform destroy` 将删除本配置创建的所有资源。

## 参考

- [SLS 文档](https://help.aliyun.com/product/28958.html)
- [alibabacloudstack_log_project](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_project)
- [alibabacloudstack_log_store](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_store)
- [alibabacloudstack_log_machine_group](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_machine_group)
- [alibabacloudstack_logtail_config](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/logtail_config)
