output "cluster_name" {
  value = length(data.alibabacloudstack_log_clusters.default.clusters) > 0 ? data.alibabacloudstack_log_clusters.default.clusters[0].name : ""
}