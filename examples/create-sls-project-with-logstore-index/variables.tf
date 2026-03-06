variable "project_name" {
  description = "The name of the SLS project to create."
  type        = string
}

variable "description" {
  description = "Description of the SLS project."
  type        = string
  default     = "Terraform managed SLS project with log store index"
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

variable "append_meta" {
  description = "Whether to append log meta automatically."
  type        = bool
  default     = true
}

variable "enable_web_tracking" {
  description = "Whether to enable Web Tracking."
  type        = bool
  default     = false
}

variable "full_text_index" {
  description = "Full text index configuration."
  type = object({
    case_sensitive  = optional(bool, false)
    include_chinese = optional(bool, false)
    token           = optional(string, "")
  })
  default = {
    case_sensitive = false
    token          = " #$%^*\r\n\t"
  }
}

variable "field_search_indexes" {
  description = "List of field search index configurations."
  type = list(object({
    name             = string
    type             = optional(string, "long")
    alias            = optional(string, null)
    case_sensitive   = optional(bool, false)
    include_chinese  = optional(bool, false)
    token            = optional(string, null)
    enable_analytics = optional(bool, true)
  }))
  default = []
}
