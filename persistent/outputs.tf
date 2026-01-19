output "static_files_bucket_name" {
  description = "Name of the S3 bucket for static files"
  value       = aws_s3_bucket.static_files.id
}

output "static_files_website_endpoint" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.static_files.website_endpoint
}

output "static_files_url" {
  description = "URL to access static files"
  value       = "http://${aws_s3_bucket_website_configuration.static_files.website_endpoint}"
}

output "upload_command" {
  description = "Command to upload static files"
  value       = "aws s3 sync ./static/ s3://${aws_s3_bucket.static_files.id}/ --delete --region ${var.region}"
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.static_files.arn
}
