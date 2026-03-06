# 带索引的 SLS 项目和日志库

本示例用于创建一个新的 SLS 项目、日志库，并配置全文索引和字段搜索索引以实现日志的实时查询和分析。

## 使用方法

1. 通过 `terraform.tfvars` 或命令行配置变量：
   ```hcl
   project_name   = "my-sls-project"
   description    = "带索引的SLS项目"
   log_store_name = "nginx-logs"
   shard_count    = 3
   
   full_text_index = {
     case_sensitive = true
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
   ```

2. 执行以下命令：
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. 清理资源：
   ```bash
   terraform destroy
   ```

## 要求

| 名称 | 版本 |
|------|------|
| terraform | >= 1.5.6 |

## 提供商

| 名称 | 版本 |
|------|------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## 模块

| 名称 | 来源 | 版本 |
|------|------|------|
| sls_project_with_index | ../../modules/sls_cluster | n/a |

## 输入变量

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| project_name | 新 SLS 项目名称 | string | - | 是 |
| description | SLS 项目描述 | string | 见描述 | 否 |
| log_store_name | 日志库名称 | string | "app-logs" | 否 |
| shard_count | 分片数量 | number | 2 | 否 |
| retention_period | 数据保留天数 | number | 30 | 否 |
| full_text_index | 全文索引配置 | object | 见描述 | 否 |
| field_search_indexes | 字段搜索索引列表 | list(object) | [] | 否 |

## 输出变量

| 名称 | 描述 |
|------|------|
| project_id | 创建的 SLS 项目 ID |
| project_name | 创建的 SLS 项目名称 |
| log_store_name | 创建的日志库名称 |
| log_store_id | 创建的日志库 ID |

## 索引配置说明

### 全文索引
- **case_sensitive**: 索引是否区分大小写
- **include_chinese**: 是否包含中文字符
- **token**: 文本分词的分隔符

### 字段搜索索引
- **name**: 字段名称
- **type**: 字段类型（long, text, double, json）
- **enable_analytics**: 是否启用该字段的分析功能
- **case_sensitive**: 是否区分大小写（适用于 text/json 类型）
- **token**: 分词分隔符（适用于 text/json 类型）
