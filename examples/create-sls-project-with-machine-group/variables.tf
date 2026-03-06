variable "project_name" {
  description = "The name of the SLS project to create."
  type        = string
}

variable "description" {
  description = "Description of the SLS project."
  type        = string
  default     = "Terraform managed SLS project with machine groups"
}

variable "log_store_name" {
  description = "The name of the log store."
  type        = string
  default     = "app-logs"
}

variable "shard_count" {
  description = "The number of shards in the log store."
  type        = number
  default     = 2
}

variable "retention_period" {
  description = "The data retention time (in days). Valid values: [1-3650]."
  type        = number
  default     = 30
}

variable "auto_split" {
  description = "Whether to automatically split a shard."
  type        = bool
  default     = true
}

variable "max_split_shard_count" {
  description = "The maximum number of shards for automatic split."
  type        = number
  default     = 64
}

variable "machine_groups" {
  description = "Map of machine group names to their configurations."
  type = map(object({
    identify_type = optional(string, "ip")
    identify_list = list(string)
    topic         = optional(string, "")
  }))
  default = {}
}

variable "logtail_configs" {
  description = "Map of logtail config names to their configurations."
  type = map(object({
    input_type   = string
    output_type  = string
    input_detail = string
  }))
  default = {}
}

variable "logtail_attachments" {
  description = "Map of logtail attachment names to their configurations."
  type = map(object({
    logtail_config_name = string
    machine_group_name  = string
  }))
  default = {}
}
