output "project_id" {
  description = "The ID of the SLS project."
  value       = module.default.project_id
}

output "project_name" {
  description = "The name of the SLS project."
  value       = module.default.project_name
}

output "log_store_name" {
  description = "The name of the SLS log store."
  value       = module.default.log_store_name
}

output "log_store_id" {
  description = "The ID of the SLS log store."
  value       = module.default.log_store_id
}
