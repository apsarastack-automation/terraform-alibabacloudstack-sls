# 带机器组的 SLS 项目

本示例用于创建一个新的 SLS 项目、日志库、机器组、Logtail 配置和关联关系，实现完整的日志采集方案。

## 使用方法

1. 通过 `terraform.tfvars` 或命令行配置变量：
   ```hcl
   project_name   = "my-sls-project"
   description    = "带机器组的SLS项目"
   log_store_name = "app-logs"
   
   machine_groups = {
     web-servers = {
       identify_type = "ip"
       identify_list = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]
       topic         = "web"
     }
     app-servers = {
       identify_type = "userdefined"
       identify_list = ["app-server-01", "app-server-02"]
       topic         = "application"
     }
   }
   
   logtail_configs = {
     nginx-access = {
       input_type   = "file"
       output_type  = "LogService"
       input_detail = jsonencode({
         logPath        = "/var/log/nginx"
         filePattern    = "access.log"
         logType        = "nginx_log"
         topicFormat    = "default"
         discardUnmatch = false
         enableRawLog   = true
         fileEncoding   = "utf8"
         maxDepth       = 10
       })
     }
   }
   
   logtail_attachments = {
     nginx-to-web = {
       logtail_config_name = "nginx-access"
       machine_group_name  = "web-servers"
     }
   }
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
| sls_project_with_machine_group | ../../modules/sls_cluster | n/a |

## 输入变量

| 名称 | 描述 | 类型 | 默认值 | 必需 |
|------|------|------|--------|------|
| project_name | 新 SLS 项目名称 | string | - | 是 |
| description | SLS 项目描述 | string | 见描述 | 否 |
| log_store_name | 日志库名称 | string | "app-logs" | 否 |
| machine_groups | 机器组配置映射 | map(object) | {} | 否 |
| logtail_configs | Logtail 配置映射 | map(object) | {} | 否 |
| logtail_attachments | Logtail 关联配置映射 | map(object) | {} | 否 |

## 输出变量

| 名称 | 描述 |
|------|------|
| project_id | 创建的 SLS 项目 ID |
| project_name | 创建的 SLS 项目名称 |
| log_store_name | 创建的日志库名称 |
| machine_group_names | 机器组名称列表 |
| logtail_config_names | Logtail 配置名称列表 |

## 机器组配置说明

### identify_type
- **ip**: 使用 IP 地址标识机器
- **userdefined**: 使用自定义标识符

### identify_list
机器组中机器的 IP 地址或自定义标识符列表。

## Logtail 配置说明

### input_type
- **file**: 从文件采集日志
- **plugin**: 使用插件方式采集

### output_type
目前仅支持 **LogService**。

### input_detail
日志采集的 JSON 配置。格式因日志类型而异。
