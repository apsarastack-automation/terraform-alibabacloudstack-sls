# Complete Log Collection Setup

This Terraform example **creates a complete log collection solution** using Alibaba Cloud Log Service (SLS).  
It includes SLS project, log store with indexes, machine groups, Logtail configurations, and attachments—**a one-stop solution for log collection and analysis**.

## Usage

1. Configure variables (via `terraform.tfvars` or command line):
   ```hcl
   project_name   = "my-complete-sls"
   description    = "Complete log collection setup"
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

2. Run the following commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. Clean up all resources:
   ```bash
   terraform destroy
   ```

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5.6 |

## Provider

| Name | Version |
|------|---------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## Module Dependency

| Module Name | Source Path |
|-------------|-------------|
| `sls_complete` | `../../modules/sls_cluster` |

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_name` | Name of the SLS project | `string` | - | Yes |
| `description` | Description of the SLS project | `string` | See description | No |
| `log_store_name` | Name of the log store | `string` | "app-logs" | No |
| `shard_count` | Number of shards | `number` | 2 | No |
| `retention_period` | Data retention in days | `number` | 30 | No |
| `auto_split` | Enable auto split | `bool` | true | No |
| `max_split_shard_count` | Max split shard count | `number` | 64 | No |
| `full_text_index` | Full text index configuration | `object` | null | No |
| `field_search_indexes` | Field search index configurations | `list(object)` | [] | No |
| `machine_groups` | Map of machine group configurations | `map(object)` | `{}` | No |
| `logtail_configs` | Map of Logtail config configurations | `map(object)` | `{}` | No |
| `logtail_attachments` | Map of Logtail attachment configurations | `map(object)` | `{}` | No |

## Output Values

| Name | Description |
|------|-------------|
| `project_id` | ID of the created SLS project |
| `project_name` | Name of the created SLS project |
| `log_store_name` | Name of the created log store |
| `log_store_id` | ID of the created log store |

## Architecture

This example sets up the following SLS resources:

1. **SLS Project** - The container for all log resources
2. **Log Store** - Storage unit for logs
3. **Log Store Indexes** - Enable search and analytics on log data
4. **Machine Groups** - Define which servers will collect logs
5. **Logtail Configs** - Define how to parse and collect logs
6. **Logtail Attachments** - Connect configs to machine groups

## Notes

- If the specified `project_name` already exists, the module will use it instead of creating a new one.
- Machine group IPs should be replaced with your actual server IPs.
- Logtail `input_detail` format varies by `logType`. Refer to SLS documentation for details.
- Running `terraform destroy` will remove all resources created by this configuration.

## References

- [SLS Documentation](https://help.aliyun.com/product/28958.html)
- [alibabacloudstack_log_project](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_project)
- [alibabacloudstack_log_store](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_store)
- [alibabacloudstack_log_machine_group](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/log_machine_group)
- [alibabacloudstack_logtail_config](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs/resources/logtail_config)
