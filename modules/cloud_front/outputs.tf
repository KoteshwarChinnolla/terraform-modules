
output "cloud_front_domain" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}

output "cloud_front_hosted_zone_id" {
  value = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
  description = "hosted zone id"
}

output "cloud_front_distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
  description = "destribution id"
}
