variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "oidc_provider" {
  type        = string
  description = "OIDC provider URL without https://"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for the service account"
}

variable "sa_name" {
  type        = string
  description = "Service account name"
}

variable "role_name" {
  type        = string
  description = "IAM Role name to be created"
}

locals {
  trust_relationship = {
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
            "${var.oidc_provider}:sub" = "system:serviceaccount:${var.namespace}:${var.sa_name}"
          }
        }
      }
    ]
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = jsonencode(local.trust_relationship)
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
