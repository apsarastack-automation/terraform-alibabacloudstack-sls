run "validate" {
  command = apply
  module {
    source = "../"
  }
  variables {
    project_name     = "tf-sls-test"
    description      = "Test SLS project"
    log_store_name   = "test-logstore"
    shard_count      = 2
    retention_period = 30
    auto_split       = true
    max_split_shard_count = 64
    append_meta      = true
    enable_web_tracking = false
  }

  assert {
    condition     = output.project_id != ""
    error_message = "SLS project ID should not be empty."
  }

  assert {
    condition     = output.project_name == "tf-sls-test"
    error_message = "SLS project name should match the input."
  }

  assert {
    condition     = output.log_store_name == "test-logstore"
    error_message = "Log store name should match the input."
  }
}
