output "project_id" {
  description = "The ID of the SLS project."
  value       = module.sls_project_with_machine_group.project_id
}

output "project_name" {
  description = "The name of the SLS project."
  value       = module.sls_project_with_machine_group.project_name
}

output "log_store_name" {
  description = "The name of the SLS log store."
  value       = module.sls_project_with_machine_group.log_store_name
}

output "machine_group_names" {
  description = "The names of the machine groups."
  value       = keys(var.machine_groups)
}

output "logtail_config_names" {
  description = "The names of the logtail configs."
  value       = keys(var.logtail_configs)
}
