run "setup" {
  command = apply
  module {
    source = "../examples/complete-log-collection-setup"
  }
}




run "validate" {
  command = apply
  module {
    source = "../examples/complete-log-collection-setup"
  }
  variables {
    project_name          = "tf-sls-complete"
    description           = "Complete SLS setup test"
    create_log_store      = true
    cluster_name          = run.setup.cluster_name
    log_store_name        = "app-logs"
    shard_count           = 2
    retention_period      = 30
    auto_split            = true
    max_split_shard_count = 64
    full_text_index = {
      case_sensitive  = false
      include_chinese = false
      token           = " #$%^*\r\n\t"
    }
    field_search_indexes = [
      {
        name             = "level"
        type             = "text"
        enable_analytics = true
      }
    ]
    machine_groups = {
      "web-servers" = {
        identify_type = "ip"
        identify_list = ["10.0.0.1", "10.0.0.2"]
        topic         = "web"
      }
    }
    logtail_configs = {
      "nginx-access" = {
        input_type   = "file"
        output_type  = "LogService"
        input_detail = "{\"discardUnmatch\":false,\"enableRawLog\":true,\"fileEncoding\":\"gbk\",\"filePattern\":\"access.log\",\"logPath\":\"/logPath\",\"logType\":\"json_log\",\"maxDepth\":10,\"topicFormat\":\"default\"}",
      }
    }
    logtail_attachments = {
      "nginx-to-web" = {
        logtail_config_name = "nginx-access"
        machine_group_name  = "web-servers"
      }
    }
  }
  assert {
    condition     = output.project_id != ""
    error_message = "SLS project creation failed"
  }
  assert {
    condition     = output.log_store_name == "app-logs"
    error_message = "Log store name should match the input"
  }
}
