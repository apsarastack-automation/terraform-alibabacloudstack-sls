# SLS Project with Log Store Index

This example creates a new SLS project with a log store and configures both full-text and field search indexes for real-time log query and analysis.

## Usage

1. Configure variables (via `terraform.tfvars` or CLI):
   ```hcl
   project_name   = "my-sls-project"
   description    = "SLS project with index"
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
| sls_project_with_index | ../../modules/sls_cluster | n/a |

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the new SLS project | string | - | Yes |
| description | Description of the SLS project | string | See description | No |
| log_store_name | Name of the log store | string | "app-logs" | No |
| shard_count | Number of shards | number | 2 | No |
| retention_period | Data retention in days | number | 30 | No |
| full_text_index | Full text index configuration | object | See description | No |
| field_search_indexes | List of field search indexes | list(object) | [] | No |

## Output Variables

| Name | Description |
|------|-------------|
| project_id | ID of the created SLS project |
| project_name | Name of the created SLS project |
| log_store_name | Name of the created log store |
| log_store_id | ID of the created log store |

## Index Configuration

### Full Text Index
- **case_sensitive**: Whether the index is case sensitive
- **include_chinese**: Whether to include Chinese characters
- **token**: Token delimiters for splitting text

### Field Search Index
- **name**: Field name
- **type**: Field type (long, text, double, json)
- **enable_analytics**: Enable analytics for this field
- **case_sensitive**: Case sensitivity (for text/json types)
- **token**: Token delimiters (for text/json types)
