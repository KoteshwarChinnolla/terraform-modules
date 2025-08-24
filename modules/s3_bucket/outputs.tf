output "bucket_domain" {
  value = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
  description = "The domain name of the S3 bucket"
}

output "s3_origin_id" {
  value = aws_s3_bucket.s3_bucket.id
  description = "The S3 bucket ID used as the origin in CloudFront distribution"
}

output "bucket_arn" {
  value = aws_s3_bucket.s3_bucket.arn
  description = "The ARN of the S3 bucket"
}