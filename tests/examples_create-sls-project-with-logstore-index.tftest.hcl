run "validate" {
  command = apply
  module {
    source = "../examples/create-sls-project-with-logstore-index"
  }
  variables {
    project_name          = "tf-sls-index"
    description           = "Test SLS project with index"
    log_store_name        = "nginx-logs"
    shard_count           = 3
    retention_period      = 30
    auto_split            = true
    max_split_shard_count = 64
    full_text_index = {
      case_sensitive  = true
      include_chinese = false
      token           = " #$%^*\r\n\t"
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
  }
  assert {
    condition     = output.project_id != ""
    error_message = "SLS project creation failed"
  }
  assert {
    condition     = output.log_store_name == "nginx-logs"
    error_message = "Log store name should match the input"
  }
  assert {
    condition     = output.project_name == "tf-sls-index"
    error_message = "Project name should match the input"
  }
}
