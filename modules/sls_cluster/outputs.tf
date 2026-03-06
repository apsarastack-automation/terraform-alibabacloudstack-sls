output "project_id" {
  description = "The ID of the SLS project."
  value       = local.sls_project_name
}

output "project_name" {
  description = "The name of the SLS project."
  value       = local.sls_project_name
}

output "log_store_name" {
  description = "The name of the SLS log store that was actually created."
  value       = local.sls_store_name
}

output "log_store_id" {
  description = "The ID of the SLS log store that was actually created."
  value       = local.sls_store_id
}
