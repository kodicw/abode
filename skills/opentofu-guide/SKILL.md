---
name: opentofu-guide
description: Comprehensive guide for OpenTofu (Terraform fork). Covers infrastructure-as-code workflows, state management, modules, workspaces, testing with tofu test, remote backends, migration from Terraform, and best practices. Use when writing, reviewing, or debugging OpenTofu configurations.
---

# OpenTofu Guide

OpenTofu is an open-source infrastructure-as-code tool forked from Terraform after HashiCorp's license change to BSL. It is managed by the Linux Foundation and remains MPL-licensed.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `tofu init` | Initialize working directory |
| `tofu plan` | Preview changes |
| `tofu apply` | Apply changes |
| `tofu destroy` | Tear down infrastructure |
| `tofu validate` | Check configuration syntax |
| `tofu fmt` | Format configuration files |
| `tofu show` | Inspect state or plan |
| `tofu state list` | List resources in state |
| `tofu import` | Bring existing resources under management |
| `tofu test` | Run native tests |
| `tofu workspace list` | Manage workspaces |

## Installation

### Nix

```nix
# In your home.packages or shell.nix
pkgs.opentofu
```

### Official (Debian/Ubuntu)

```bash
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh
```

### Verify Version

```bash
tofu --version
# OpenTofu v1.6.x
# on linux_amd64
```

## Core Concepts

### Configuration Files

| File | Purpose |
|------|---------|
| `main.tf` | Primary resource definitions |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Output value declarations |
| `providers.tf` | Provider configuration |
| `backend.tf` | Remote state backend config |
| `versions.tf` | Provider and OpenTofu version constraints |
| `*.tfvars` | Variable value files |

### Provider

A plugin that manages a specific API (AWS, Azure, GCP, Kubernetes, etc.).

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### Resource

A component of your infrastructure (VPC, VM, database, DNS record).

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "web-server"
  }
}
```

### Data Source

Read-only query of existing infrastructure.

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
```

## Variables

### Declaration (`variables.tf`)

| Type | Declaration |
|------|------------|
| `string` | `variable "env" { type = string; default = "dev" }` |
| `number` | `variable "count" { type = number; default = 1 }` |
| `list(string)` | `variable "cidrs" { type = list(string); default = ["10.0.0.0/8"] }` |
| `map(string)` | `variable "tags" { type = map(string); default = {} }` |
| `object({...})` | `variable "cfg" { type = object({ enabled = bool; retention = number }) }` |
| `bool` | `variable "enabled" { type = bool; default = true }` |

Full example with validation:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Usage

```hcl
resource "aws_instance" "web" {
  count         = var.instance_count
  instance_type = "t3.micro"
  tags          = var.tags
}
```

### Variable Files

```bash
# terraform.tfvars
environment    = "prod"
instance_count = 3

# Override with:
tofu apply -var-file="production.tfvars"
tofu apply -var="environment=staging"
```

### Environment Variables

```bash
export TF_VAR_environment="staging"
export TF_VAR_instance_count="2"
tofu apply
```

## Outputs

```hcl
output "instance_ips" {
  description = "Public IPs of created instances"
  value       = aws_instance.web[*].public_ip
  sensitive   = false
}

output "db_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true  # Masked in CLI output
}
```

## The Standard Workflow

```
tofu init      # Download providers, initialize backend
tofu fmt       # Format all .tf files
tofu validate  # Check syntax and types
tofu plan      # Preview changes (always review)
tofu apply     # Execute changes
```

### Planning Best Practices

- Always run `tofu plan` before `apply`
- Save plans for CI/CD: `tofu plan -out=tfplan`
- Apply saved plans: `tofu apply tfplan`
- Plans are binary and sensitive — do not commit them

```bash
tofu plan -out=tfplan
tofu apply tfplan        # Exact plan execution
tofu show tfplan         # Human-readable plan
tofu show -json tfplan   # Machine-readable plan
```

## State Management

State tracks the mapping between configuration and real infrastructure. **Never edit state files manually.**

### Local State

Default: `terraform.tfstate` and `terraform.tfstate.backup` in the working directory.

**Problem**: Not shareable, no locking, risk of loss.

### Remote Backends

#### S3 Backend (Recommended for AWS)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tofu-state-bucket"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tofu-state-lock"
  }
}
```

DynamoDB table for locking:

```hcl
resource "aws_dynamodb_table" "state_lock" {
  name         = "tofu-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

#### Other Backends (minimal config)

| Backend | Minimal Config |
|---------|---------------|
| GCS | `backend "gcs" { bucket = "..."; prefix = "..." }` |
| Azure | `backend "azurerm" { resource_group_name = "..."; storage_account_name = "..."; container_name = "..."; key = "..." }` |
| PostgreSQL | `backend "pg" { conn_str = "postgres://user:pass@localhost/tofu_state" }` |

### State Commands

```bash
tofu state list                    # All resources
tofu state show aws_instance.web   # Specific resource
tofu state pull > state.json       # Export state
tofu state rm aws_instance.web     # Remove from state (does not destroy)
tofu state mv aws_instance.old aws_instance.new  # Rename in state
```

### State Security

- Enable encryption at rest (S3, GCS, Azure all support this)
- Restrict access to state — it may contain secrets
- Use `sensitive = true` on outputs
- Never commit `.tfstate` files to git

## Modules

Modules are reusable, composable units of infrastructure.

### Creating a Module

```
modules/vpc/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

```hcl
# modules/vpc/variables.tf
variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}

# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone = var.azs[count.index]
}

# modules/vpc/outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.public[*].id
}
```

### Using a Module

```hcl
module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
  azs        = ["us-east-1a", "us-east-1b"]
}

resource "aws_instance" "web" {
  subnet_id = module.vpc.subnet_ids[0]
}
```

### Module Sources

```hcl
# Local path
source = "./modules/vpc"

# Git repository
source = "git::https://github.com/org/terraform-modules.git//modules/vpc?ref=v1.2.0"

# Terraform Registry (OpenTofu compatible)
source = "terraform-aws-modules/vpc/aws"
version = "5.0.0"

# S3 bucket
source = "s3::https://s3.amazonaws.com/bucket/modules/vpc.zip"
```

### Module Versioning

Always pin module versions. Never use `latest` in production.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Semver constraint
}
```

## Workspaces

Workspaces manage multiple states for the same configuration (e.g., dev/staging/prod).

```bash
tofu workspace list          # Show workspaces
tofu workspace new staging   # Create and switch
tofu workspace select prod   # Switch existing
tofu workspace show          # Current workspace
tofu workspace delete old    # Remove workspace
```

```hcl
# Workspace-aware configuration
locals {
  environment = terraform.workspace
  instance_size = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

resource "aws_instance" "web" {
  instance_type = local.instance_size[local.environment]
}
```

**Alternative**: Use separate directories with separate backends for stronger isolation.

## Testing with tofu test

OpenTofu includes a native testing framework (no external tools needed).

### Test Files

Tests live in `tests/` or `*.tftest.hcl` files alongside configuration.

```hcl
# tests/main.tftest.hcl
run "create_vpc" {
  command = apply

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block incorrect"
  }
}

run "validate_subnets" {
  command = plan

  variables {
    azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Expected 3 subnets"
  }
}
```

### Running Tests

```bash
tofu test              # Run all tests
tofu test -verbose     # Detailed output
tofu test -filter=create_vpc  # Single test
```

### Test Commands

| Command | Behavior |
|---------|----------|
| `plan`  | Run assertions against plan output |
| `apply` | Create resources, run assertions, destroy |

### Mock Providers (for unit-like tests)

```hcl
mock_provider "aws" {}

run "unit_test" {
  command = plan

  assert {
    condition     = aws_instance.web.instance_type == "t3.micro"
    error_message = "Wrong instance type"
  }
}
```

## Importing Existing Infrastructure

Bring manually-created resources under OpenTofu management.

```bash
# 1. Write the resource block (without arguments that can't be set)
resource "aws_instance" "imported" {
  # Leave empty or set known values
}

# 2. Import into state
tofu import aws_instance.imported i-1234567890abcdef0

# 3. Run plan to see drift, then fill in the config
tofu plan
```

### Import Blocks (OpenTofu 1.5+)

Declarative import — define imports in configuration:

```hcl
import {
  to = aws_instance.imported
  id = "i-1234567890abcdef0"
}

resource "aws_instance" "imported" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}
```

Run `tofu plan` to preview the import, then `tofu apply` to execute.

## Migration from Terraform

### In-Place Migration

OpenTofu is a drop-in replacement for Terraform 1.5.x and earlier.

```bash
# 1. Backup state
cp terraform.tfstate terraform.tfstate.backup

# 2. Replace binary
# Install opentofu (nix, package manager, or binary)

# 3. Update lock file
tofu init -upgrade

# 4. Verify
tofu plan
# Should show: "No changes. Your infrastructure matches the configuration."
```

### State File Compatibility

- OpenTofu reads Terraform state files natively
- Terraform cannot read OpenTofu state files (after OpenTofu-specific features are used)
- Remote state backends are fully compatible

### Provider Compatibility

- All HashiCorp providers work unchanged
- Community providers work unchanged
- Provider registry URLs: `registry.opentofu.org` mirrors `registry.terraform.io`

### Lock File

OpenTofu uses `.terraform.lock.hcl` — same format, compatible.

```bash
tofu init -upgrade    # Update providers and lock file
```

## Best Practices

### Project Structure

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
├── modules/
│   ├── vpc/
│   ├── compute/
│   └── database/
├── global/
│   └── iam/
└── tests/
```

### Version Constraints

```hcl
terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### Secrets Management

**Never hardcode secrets in .tf files.**

| Method | Use Case |
|--------|----------|
| Environment variables | CI/CD, local dev |
| `tofu.tfvars` (gitignored) | Local overrides |
| AWS Secrets Manager / Azure Key Vault | Production secrets |
| HashiCorp Vault | Enterprise secret management |

```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db.secret_string
}
```

### Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  lifecycle {
    prevent_destroy = true        # Block accidental destruction
    ignore_changes  = [ami]       # Don't replace on AMI updates
    create_before_destroy = true  # Zero-downtime replacement
  }
}
```

### Count and For Each

```hcl
# Count (ordered, integer-indexed)
resource "aws_instance" "web" {
  count         = 3
  instance_type = "t3.micro"
}
# References: aws_instance.web[0], aws_instance.web[1], aws_instance.web[2]

# For each (unordered, map/set-based)
locals {
  subnets = {
    "web"    = "10.0.1.0/24"
    "app"    = "10.0.2.0/24"
    "db"     = "10.0.3.0/24"
  }
}

resource "aws_subnet" "main" {
  for_each = local.subnets

  cidr_block = each.value
  tags = {
    Name = each.key
  }
}
# References: aws_subnet.main["web"], aws_subnet.main["app"]
```

### Dynamic Blocks

```hcl
resource "aws_security_group" "web" {
  name = "web-sg"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

## Common Pitfalls

| Issue | Solution |
|-------|----------|
| State file committed to git | Add `*.tfstate*` to `.gitignore` |
| Forgot to use remote backend | Migrate early, before team grows |
| Hardcoded secrets | Use variables, env vars, or secret stores |
| No state locking | Configure DynamoDB / native locking |
| `tofu apply` without plan review | Always plan first in production |
| Module versions unpinned | Always specify `version` constraint |
| Using `count` with resources that need stable IDs | Use `for_each` with string keys |
| Large state files | Split into smaller workspaces or separate configurations |
| Provider credentials in code | Use IAM roles, env vars, or credential files |
| Not running `tofu fmt` | Add to CI or pre-commit hooks |

## CI/CD Integration

### GitHub Actions Example

```yaml
name: OpenTofu

on:
  push:
    branches: [main]
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: opentofu/setup-opentofu@v1

      - name: Format Check
        run: tofu fmt -check -recursive

      - name: Initialize
        run: tofu init

      - name: Validate
        run: tofu validate

      - name: Plan
        run: tofu plan -no-color
```

### Plan in PR, Apply on Merge

```yaml
  - name: Plan
    if: github.event_name == 'pull_request'
    run: tofu plan -no-color -out=tfplan

  - name: Apply
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    run: tofu apply -auto-approve tfplan
```

## Useful Functions

```hcl
# String
upper("hello")        # "HELLO"
lower("HELLO")        # "hello"
replace("a-b-c", "-", "_")  # "a_b_c"
substr("hello", 0, 4) # "hell"

# Numeric
max(1, 2, 3)          # 3
min(1, 2, 3)          # 1
ceil(1.2)             # 2
floor(1.8)            # 1

# Collection
length(["a", "b"])    # 2
merge({a=1}, {b=2})   # {a=1, b=2}
keys({a=1, b=2})      # ["a", "b"]
values({a=1, b=2})    # [1, 2]
contains(["a", "b"], "a")  # true

# Encoding
base64encode("hello") # "aGVsbG8="
jsonencode({a=1})     # '{"a":1}'
yamlencode({a=1})     # "a: 1\n"

# Filesystem
file("script.sh")           # Read file contents
filebase64("image.png")     # Base64 encode file
templatefile("user-data.sh", { name = "web" })
fileexists("config.tf")     # true/false

# IP Network
cidrsubnet("10.0.0.0/16", 8, 1)  # "10.0.1.0/24"
cidrhost("10.0.0.0/24", 5)       # "10.0.0.5"
```

## Debugging

```bash
# Verbose logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./tofu.log
tofu apply

# Log levels: TRACE, DEBUG, INFO, WARN, ERROR
# Disable: unset TF_LOG

# Graph visualization
tofu graph | dot -Tpng > graph.png

# Refresh state without applying
tofu refresh

# Target specific resources
tofu apply -target=aws_instance.web

# Replace (taint) a resource
tofu taint aws_instance.web
tofu apply

# Untaint
tofu untaint aws_instance.web
```

## Resources

| Resource | URL |
|----------|-----|
| OpenTofu Docs | https://opentofu.org/docs/ |
| Registry | https://search.opentofu.org/ |
| GitHub | https://github.com/opentofu/opentofu |
| Slack | https://opentofu.org/slack |
| Terraform Migration Guide | https://opentofu.org/docs/intro/migration/ |
