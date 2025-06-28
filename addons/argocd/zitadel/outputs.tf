output "url" {
  value = format("https://%s", try(yamldecode((data.utils_deep_merge_yaml.main.output))["ingress"]["hosts"][0]["host"], ""))
}
