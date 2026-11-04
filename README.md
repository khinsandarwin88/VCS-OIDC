# AWS VPC Peering — VCS-Driven Workflow on HCP Terraform

Frontend VPC (`10.0.0.0/16`) and backend VPC (`192.168.0.0/16`) in `eu-west-1`, joined by VPC peering, deployed by **HCP Terraform VCS-driven runs** from GitHub.

- **AWS auth:** OIDC dynamic credentials, separate **Plan** (read-only) and **Apply** roles — no static access keys.
- **SSH keys:** generated on the Mac with `ssh-keygen`, stored in **AWS Secrets Manager**. Terraform reads the public key with a data source and the private key with an **ephemeral** resource, so the private key never appears in a plan, state file, run log or this repository.
- **Organization:** `waiaung` · **Project:** `aws-vpc-peering-infra`

## 1. Architecture

| | Frontend VPC `10.0.0.0/16` | Backend VPC `192.168.0.0/16` |
|---|---|---|
| Public subnets | `10.0.1-3.0/24` → IGW | `192.168.1-3.0/24` → IGW |
| Private subnet01 | `10.0.253.0/24` → NAT | `192.168.253.0/24` → NAT |
| Private subnet02 | `10.0.254.0/24` ↔ peering ↔ | `192.168.254.0/24` |
| Private subnet03 | `10.0.255.0/24` ↔ peering ↔ | `192.168.255.0/24` |
| Public instance01 | Amazon Linux 2023, EIP, httpd, bastion | same |
| Private instance01–03 | Ubuntu 24.04 | Ubuntu 24.04 |

Access path: Mac → public instance (bastion) → private instance01 → private instance02/03.
Peering traffic (SSH + ICMP) is allowed only between private SG02 ↔ SG02 and SG03 ↔ SG03.

## 2. Workspaces (monorepo, one folder = one workspace)

| Order | Workspace | Working directory | Trigger pattern | Builds | Reads from |
|:-:|---|---|---|---|---|
| 1 | `fe-network-ws` | `fe-network` | `fe-network/**/*` | Frontend VPC, subnets, IGW, NAT, route tables | — |
| 2 | `be-network-ws` | `be-network` | `be-network/**/*` | Backend VPC, subnets, IGW, NAT, route tables + **peering** | fe-network |
| 3 | `fe-security-ws` | `fe-security` | `fe-security/**/*` | Frontend SGs | fe-network |
| 4 | `be-security-ws` | `be-security` | `be-security/**/*` | Backend SGs + **cross-VPC rules (both sides)** | be-network, fe-security |
| 5 | `fe-compute-ws` | `fe-compute` | `fe-compute/**/*` | Key pair, public + 3 private instances | fe-network, fe-security |
| 6 | `be-compute-ws` | `be-compute` | `be-compute/**/*` | Key pair, public + 3 private instances | be-network, be-security |

Peering lives in `be-network` and cross-VPC rules in `be-security` because frontend and backend reference each other: frontend is created first, backend adds the links. This avoids a circular dependency.

**Remote state sharing** (source workspace → Settings → General):

- `fe-network-ws` → `be-network-ws`, `fe-security-ws`, `fe-compute-ws`
- `be-network-ws` → `be-security-ws`, `be-compute-ws`
- `fe-security-ws` → `be-security-ws`, `fe-compute-ws`
- `be-security-ws` → `be-compute-ws`

## 3. AWS authentication (OIDC)

Variable set on project `aws-vpc-peering-infra` (category **Environment**):

| Key | Value | Sensitive |
|---|---|---|
| `TFC_AWS_PROVIDER_AUTH` | `true` | No |
| `TFC_AWS_PLAN_ROLE_ARN` | `arn:aws:iam::<ACCOUNT_ID>:role/HCP-Terraform-Plan-Role` | Yes |
| `TFC_AWS_APPLY_ROLE_ARN` | `arn:aws:iam::<ACCOUNT_ID>:role/HCP-Terraform-Apply-Role` | Yes |

- Plan role: `ReadOnlyAccess` + `iam/secrets-read-policy.json`
- Apply role: `AdministratorAccess` (lab) + `iam/secrets-read-policy.json`
- Trust policy `sub`: `organization:waiaung:project:aws-vpc-peering-infra:workspace:*:run_phase:plan` (or `apply`)

## 4. SSH keys — Mac → AWS Secrets Manager

```bash
bash scripts/create-ssh-keys.sh
```

| Secret | Terraform reads it as |
|---|---|
| `vcs-workflow/<tier>/ssh-public-key` | `data "aws_secretsmanager_secret_version"` → `aws_key_pair` |
| `vcs-workflow/<tier>/ssh-private-key` | `ephemeral "aws_secretsmanager_secret_version"` → provisioner `connection` only |

## 5. Change workflow (GitOps)

```bash
git checkout -b feature/fe-compute-instance-type
# edit files in fe-compute/
git add fe-compute/ && git commit -m "Change frontend instance type"
git push -u origin feature/fe-compute-instance-type
```

Open a pull request → only `fe-compute-ws` runs a speculative plan → review → merge → confirm & apply.
Change one folder per pull request so workspaces run in dependency order.

## 6. Test

```bash
ssh-add ~/.ssh/vcs-workflow/frontend-ssh-key
curl http://<frontend_public_instance_public_ip>
ssh -J ec2-user@<frontend_public_ip> ubuntu@<frontend_private_instance01_private_ip>
# from fe private-instance01 -> fe private-instance02 (agent forwarding: ssh -A)
# from fe private-instance02: ping <backend_private_instance02_private_ip>
```

## 7. Destroy (reverse order)

`be-compute` → `fe-compute` → `be-security` → `fe-security` → `be-network` → `fe-network`, then delete the four secrets (`--force-delete-without-recovery`).

## Cost note

Each VPC has a NAT gateway and every Elastic IP is billed hourly. Destroy the lab when finished.
