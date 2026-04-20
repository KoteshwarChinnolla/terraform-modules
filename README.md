# terraform-modules

A collection of production-ready, reusable Terraform modules for provisioning AWS infrastructure. Each module is self-contained with its own inputs, outputs, and sane defaults — compose them together to build full environments in minutes.

---

## 📦 Repository Structure

```
terraform-modules/
├── modules/                  # ✅ Reusable modules (use these in your own Terraform)
│   ├── vpc/                  #    VPC, subnets, route tables, IGW, NAT
│   ├── ec2_instance/         #    EC2 with key pair, SG, and optional user data
│   ├── asg/                  #    Auto Scaling Group with launch template
│   ├── alb/                  #    Application Load Balancer + target groups
│   ├── ecs/                  #    ECS Fargate cluster + service + task definition
│   ├── eks/                  #    EKS cluster + managed node groups
│   ├── rds/                  #    RDS (PostgreSQL/MySQL) with subnet group + SG
│   ├── ecr/                  #    ECR private repository
│   ├── s3_bucket/            #    S3 bucket with versioning + policies
│   ├── cloud_front/          #    CloudFront distribution + origin config
│   ├── acm_ROOT_CERT/        #    ACM certificate for root domain
│   ├── acm_SUB_ROOT_CERT/    #    ACM certificate for subdomains
│   ├── route_53/             #    Route53 hosted zone + DNS records
│   ├── IAM_grops_poicy/      #    IAM groups + policies + attachments
│   └── iam_oidc_trust_polecy/#    IAM OIDC provider + trust policy (for EKS IRSA)
│
├── ec2/                      # 📖 Example: single EC2 instance deployment
├── ec2_production_ready/     # 📖 Example: EC2 with ALB, ASG, and scripts
├── ecs-rds/                  # 📖 Example: ECS Fargate + RDS full stack
├── eks_cluster/              # 📖 Example: full EKS cluster with node groups
├── iam_user_groups/          # 📖 Example: IAM users, groups, and policies
├── creat_ecr_registry/       # 📖 Example: ECR registry creation
├── webhosting/               # 📖 Example: static site on S3 + CloudFront + Route53
└── .github/workflows/        # 🔁 GitHub Actions: EKS provisioning + web hosting CI/CD
```

> **Modules** live in `modules/` and are the reusable building blocks.
> **Example folders** (e.g., `ec2/`, `eks_cluster/`) show you exactly how to wire the modules together for real deployments using a `use.tfvars` file.

---

## 🧩 Available Modules

### `vpc`
Provisions a complete AWS VPC with public and private subnets across availability zones, internet gateway, NAT gateway, and route tables.

**Key inputs:** CIDR block, AZ list, public/private subnet CIDRs, NAT gateway toggle
**Outputs:** VPC ID, subnet IDs, route table IDs

---

### `ec2_instance`
Deploys a single EC2 instance with a configurable AMI, instance type, key pair, security group, and optional user data script.

**Key inputs:** AMI ID, instance type, subnet ID, key name, user data script path
**Outputs:** Instance ID, public IP, private IP

---

### `asg`
Creates an Auto Scaling Group using a launch template with configurable min/max/desired capacity, health checks, and instance type.

**Key inputs:** AMI ID, instance type, min/max/desired capacity, VPC zone identifiers, target group ARN
**Outputs:** ASG name, launch template ID

---

### `alb`
Provisions an Application Load Balancer with HTTP/HTTPS listeners, target groups, and optional SSL certificate attachment.

**Key inputs:** VPC ID, subnet IDs, certificate ARN, target group port/protocol, health check path
**Outputs:** ALB DNS name, ALB ARN, target group ARN

---

### `ecs`
Deploys an ECS Fargate cluster with a task definition and service. Integrates with ALB target groups and supports environment variables and secrets from SSM/Secrets Manager.

**Key inputs:** Cluster name, task CPU/memory, container image, port mappings, ALB target group ARN, subnet IDs, security group IDs
**Outputs:** Cluster ARN, service name, task definition ARN

---

### `eks`
Provisions a production-grade EKS cluster with managed node groups, configurable instance types, and IAM roles. Works with the `iam_oidc_trust_polecy` module to enable IRSA (IAM Roles for Service Accounts).

**Key inputs:** Cluster name, Kubernetes version, node group instance types, desired/min/max node count, subnet IDs
**Outputs:** Cluster endpoint, cluster CA, cluster name, node group role ARN

---

### `rds`
Creates an RDS instance (PostgreSQL or MySQL) inside a private subnet group, with a dedicated security group, storage config, and optional multi-AZ.

**Key inputs:** Engine type/version, instance class, DB name, username, password, subnet IDs, VPC ID, storage size
**Outputs:** RDS endpoint, DB port, DB name

---

### `ecr`
Creates a private ECR repository with configurable image tag mutability and lifecycle policies.

**Key inputs:** Repository name, tag mutability, lifecycle policy
**Outputs:** Repository URL, repository ARN

---

### `s3_bucket`
Provisions an S3 bucket with optional versioning, server-side encryption, public access block, and bucket policy.

**Key inputs:** Bucket name, versioning toggle, ACL, lifecycle rules, policy JSON
**Outputs:** Bucket name, bucket ARN, bucket regional domain name

---

### `cloud_front`
Creates a CloudFront distribution fronting an S3 origin or custom origin, with HTTPS enforcement and optional custom domain + ACM certificate.

**Key inputs:** Origin domain, ACM certificate ARN, aliases (custom domains), price class, cache behaviors
**Outputs:** CloudFront domain name, distribution ID

---

### `acm_ROOT_CERT`
Requests an ACM public TLS certificate for a **root domain** (e.g., `example.com`) using DNS validation.

**Key inputs:** Domain name, Route53 hosted zone ID
**Outputs:** Certificate ARN

---

### `acm_SUB_ROOT_CERT`
Requests an ACM public TLS certificate for a **subdomain or wildcard** (e.g., `*.example.com`) using DNS validation.

**Key inputs:** Domain name, Route53 hosted zone ID
**Outputs:** Certificate ARN

---

### `route_53`
Manages a Route53 hosted zone and DNS records. Typically used to wire up ALB or CloudFront domains to your custom domain.

**Key inputs:** Zone name, record name, record type (A/CNAME), alias target
**Outputs:** Hosted zone ID, name servers

---

### `IAM_grops_poicy`
Creates IAM groups, attaches managed or inline policies, and manages group membership for users.

**Key inputs:** Group name, policy ARNs, inline policy JSON, user list
**Outputs:** Group ARN, group name

---

### `iam_oidc_trust_polecy`
Creates an IAM OIDC identity provider for an EKS cluster and sets up a trust policy allowing specific Kubernetes service accounts to assume an IAM role (IRSA pattern).

**Key inputs:** EKS OIDC issuer URL, namespace, service account name, role policy ARN
**Outputs:** IAM role ARN

---

## 📖 Usage Examples

Each example folder contains a `main.tf` (which calls the relevant modules), a `variables.tf`, an `output.tf`, and a `use.tfvars` with real values to fill in. Use them as starting points.

---

### Example: Single EC2 Instance — `ec2/`

Deploys a standalone EC2 instance, optionally with bootstrapping scripts for installs, deployments, and S3 backups.

```hcl
module "ec2" {
  source        = "../modules/ec2_instance"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
}
```

Included scripts in `ec2/scripts/`:

| Script | Purpose |
|---|---|
| `install.sh` | Installs required packages on the instance |
| `deploy.sh` | Pulls and runs your application |
| `s3_backup.sh` | Backs up data to an S3 bucket |
| `se_backup.sh` | Secondary backup helper |

---

### Example: Production EC2 — `ec2_production_ready/`

A production-hardened setup combining EC2 + ALB + ASG for high availability — suitable for stateless web applications that need horizontal scaling and traffic distribution.

**Modules used:** `vpc`, `ec2_instance`, `asg`, `alb`

---

### Example: ECS + RDS Full Stack — `ecs-rds/`

Deploys a containerised backend service on ECS Fargate connected to a private RDS database. Ideal for API services that need a managed database backend with no EC2 to maintain.

**Modules used:** `vpc`, `ecs`, `rds`, `alb`, `ecr`

```hcl
# use.tfvars
cluster_name    = "my-app-cluster"
container_image = "123456.dkr.ecr.ap-south-1.amazonaws.com/my-app:latest"
db_engine       = "postgres"
db_name         = "appdb"
db_username     = "admin"
```

---

### Example: EKS Cluster — `eks_cluster/`

Provisions a full EKS cluster with managed node groups, IAM roles, and OIDC trust policy for IRSA. Pairs perfectly with the [helm-utilities](https://github.com/KoteshwarChinnolla/helm-utilities) repo to deploy workloads onto the cluster.

**Modules used:** `vpc`, `eks`, `iam_oidc_trust_polecy`

```hcl
# use.tfvars
cluster_name   = "hrms-cluster"
k8s_version    = "1.29"
instance_types = ["t3.medium"]
desired_size   = 2
min_size       = 1
max_size       = 5
```

**GitHub Actions workflow:** `.github/workflows/creat_eks_cluster.yaml` automates the full EKS provisioning pipeline on push.

---

### Example: IAM Users & Groups — `iam_user_groups/`

Creates IAM user groups with scoped permission policies. Useful for onboarding teams with least-privilege access (e.g., developers, read-only auditors, DevOps engineers).

**Modules used:** `IAM_grops_poicy`

---

### Example: ECR Registry — `creat_ecr_registry/`

Quickly provisions one or more ECR private repositories for storing Docker images.

**Modules used:** `ecr`

```hcl
# use.tfvars
repository_name      = "hrms/employee"
image_tag_mutability = "MUTABLE"
```

---

### Example: Static Website Hosting — `webhosting/`

Full serverless static site pipeline: S3 bucket for content + CloudFront for global CDN + ACM for HTTPS + Route53 for custom domain.

**Modules used:** `s3_bucket`, `cloud_front`, `acm_ROOT_CERT`, `acm_SUB_ROOT_CERT`, `route_53`

**GitHub Actions workflow:** `.github/workflows/host_webpage.yaml` automates `terraform apply` and site content deployment on every push.

---

## 🔁 GitHub Actions CI/CD

| Workflow | Trigger | What it does |
|---|---|---|
| `creat_eks_cluster.yaml` | Push / manual dispatch | Runs `terraform init → plan → apply` to provision the EKS cluster |
| `host_webpage.yaml` | Push to main | Provisions S3 + CloudFront infrastructure and uploads site content |

---

## 🚀 Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/KoteshwarChinnolla/terraform-modules.git
cd terraform-modules
```

### 2. Pick an example
```bash
cd eks_cluster   # or ec2/, ecs-rds/, webhosting/, etc.
```

### 3. Fill in your values
```bash
cp use.tfvars terraform.tfvars
# edit terraform.tfvars with your actual values
```

### 4. Deploy
```bash
terraform init
terraform plan  -var-file="use.tfvars"
terraform apply -var-file="use.tfvars"
```

---

## ⚙️ Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Terraform | >= 1.3 | Infrastructure provisioning |
| AWS CLI | >= 2.x | AWS authentication |
| AWS credentials | — | IAM user or role with appropriate permissions |
| kubectl | >= 1.25 | Post-EKS cluster management |
| Docker | — | Building and pushing images to ECR |

Configure AWS credentials before running any module:
```bash
aws configure
# or use environment variables:
# AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
```

---

## 🔐 Remote State (Recommended)

For team usage, configure a remote backend in each example's `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-tfstate-bucket"
    key            = "eks_cluster/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

---

## 📄 License

See [LICENSE](./LICENSE) for details.

---

## 👤 Author

**Koteshwar Chinnolla**
- GitHub: [KoteshwarChinnolla](https://github.com/KoteshwarChinnolla)
- Related: [helm-utilities](https://github.com/KoteshwarChinnolla/helm-utilities) — Helm charts for Kubernetes deployments
