run "validate" {
  command = apply
  module {
    source = "../examples/create-sls-project-with-machine-group"
  }
  variables {
    project_name          = "tf-sls-mg"
    description           = "Test SLS project with machine groups"
    log_store_name        = "app-logs"
    shard_count           = 2
    retention_period      = 30
    auto_split            = true
    max_split_shard_count = 64
    machine_groups = {
      "web-servers" = {
        identify_type = "ip"
        identify_list = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]
        topic         = "web"
      }
      "app-servers" = {
        identify_type = "userdefined"
        identify_list = ["app-server-01", "app-server-02"]
        topic         = "application"
      }
    }
    logtail_configs = {
      "nginx-access" = {
        input_type   = "file"
        output_type  = "LogService"
        input_detail = "{\"discardUnmatch\":false,\"enableRawLog\":true,\"fileEncoding\":\"gbk\",\"filePattern\":\"access.log\",\"logPath\":\"/logPath\",\"logType\":\"json_log\",\"maxDepth\":10,\"topicFormat\":\"default\"}"
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
  assert {
    condition     = length(output.machine_group_names) == 2
    error_message = "Should have 2 machine groups"
  }
  assert {
    condition     = length(output.logtail_config_names) == 1
    error_message = "Should have 1 logtail config"
  }
}
