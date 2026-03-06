terraform {
  required_version = ">= 1.5.6"
  required_providers {
    alibabacloudstack = {
      source  = "aliyun/alibabacloudstack"
      version = ">= 3.18.24, < 3.19.0"
    }
  }
}
