# SLS Project with Machine Groups

This example creates a new SLS project with log store, machine groups, Logtail configurations, and attachments for comprehensive log collection.

## Usage

1. Configure variables (via `terraform.tfvars` or CLI):
   ```hcl
   project_name   = "my-sls-project"
   description    = "SLS project with machine groups"
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

2. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. Clean up:
   ```bash
   terraform destroy
   ```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.6 |

## Provider

| Name | Version |
|------|---------|
| alibabacloudstack | >= 3.18.24, < 3.19.0 |

## Module

| Name | Source | Version |
|------|--------|---------|
| sls_project_with_machine_group | ../../modules/sls_cluster | n/a |

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the new SLS project | string | - | Yes |
| description | Description of the SLS project | string | See description | No |
| log_store_name | Name of the log store | string | "app-logs" | No |
| machine_groups | Map of machine group configurations | map(object) | {} | No |
| logtail_configs | Map of Logtail config configurations | map(object) | {} | No |
| logtail_attachments | Map of Logtail attachment configurations | map(object) | {} | No |

## Output Variables

| Name | Description |
|------|-------------|
| project_id | ID of the created SLS project |
| project_name | Name of the created SLS project |
| log_store_name | Name of the created log store |
| machine_group_names | List of machine group names |
| logtail_config_names | List of Logtail config names |

## Machine Group Configuration

### identify_type
- **ip**: Use IP addresses to identify machines
- **userdefined**: Use custom identifiers

### identify_list
List of IP addresses or custom identifiers for the machines in the group.

## Logtail Config Configuration

### input_type
- **file**: Collect logs from files
- **plugin**: Use plugin-based collection

### output_type
Currently only **LogService** is supported.

### input_detail
JSON configuration for log collection. Format varies by log type.
