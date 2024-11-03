output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.static-site.s3_bucket_id
}

output "cloudfront_distribution_id" {
  description = "The Arn of the cloudfront distribution"
  value       = module.static-site.cloudfront_distribution_id
}