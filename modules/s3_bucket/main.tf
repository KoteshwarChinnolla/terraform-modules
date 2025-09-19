resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = var.privacy == "private" ? true : false
  block_public_policy     = var.privacy == "private" ? true : false
  ignore_public_acls      = var.privacy == "private" ? true : false
  restrict_public_buckets = var.privacy == "private" ? true : false
}

# resource "aws_s3_bucket_acl" "s3_bucket_acl" {
#   depends_on = [aws_s3_bucket_public_access_block.public_access_block]
#   bucket     = aws_s3_bucket.s3_bucket.id
#   acl        = var.privacy
# }

locals {
  folder_path  = var.folder_path != "" ? var.folder_path : null
  s3_origin_id = "s3-origin-${var.bucket_name}"
}

resource "aws_s3_object" "file_upload" {
  for_each     = local.folder_path != null ? toset(fileset(local.folder_path, "**/*")) : toset([])

  bucket = aws_s3_bucket.s3_bucket.id
  key    = each.value
  source = "${local.folder_path}/${each.value}"

  etag = filemd5("${local.folder_path}/${each.value}")

  content_type = lookup(
    {
      ".html" = "text/html"
      ".json" = "application/json"
      ".css"  = "text/css"
      ".js"   = "application/javascript"
      ".map"  = "application/octet-stream"
      ".png"  = "image/png"
      ".jpg"  = "image/jpeg"
      ".jpeg" = "image/jpeg"
      ".svg"  = "image/svg+xml"
    },
    regex("\\.[^.]+$", each.value),
    "binary/octet-stream"
  )

  cache_control = "max-age=3600"
}

resource "aws_s3_bucket_website_configuration" "web_hosting" {
  count  = var.enable_website ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  count  = var.privacy == "public-read" || var.privacy == "public" ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "private" {
  count  = var.privacy == "private" && var.cloudfront_enabled == false ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3_bucket.arn}/*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
