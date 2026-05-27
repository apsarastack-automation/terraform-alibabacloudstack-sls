variable "project_name" {
  description = "The name of the SLS project."
  type        = string
}

variable "cluster_name" {
  description = "The name of the SLS cluster. If empty, will use the first cluster from data source."
  type        = string
  default     = ""
}

variable "description" {
  description = "A brief description of the SLS project."
  type        = string
  default     = ""
}

# --- Log Store Variables ---

variable "log_store_name" {
  description = "The name of the log store."
  type        = string
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
  default     = false
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

# --- Log Store Index Variables ---

variable "full_text_index" {
  description = "Full text index configuration."
  type = object({
    case_sensitive  = optional(bool, false)
    include_chinese = optional(bool, false)
    token           = optional(string, "")
  })
  default = null
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

# --- Other Resources ---

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
