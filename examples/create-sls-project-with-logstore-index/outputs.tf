output "project_id" {
  description = "The ID of the SLS project."
  value       = module.sls_project_with_index.project_id
}

output "project_name" {
  description = "The name of the SLS project."
  value       = module.sls_project_with_index.project_name
}

output "log_store_name" {
  description = "The name of the SLS log store."
  value       = module.sls_project_with_index.log_store_name
}

output "log_store_id" {
  description = "The ID of the SLS log store."
  value       = module.sls_project_with_index.log_store_id
}
