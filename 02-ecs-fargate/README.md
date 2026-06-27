# 02 – ECS Fargate

Dieses Projekt baut auf `01-ec2-introduction` auf und zeigt, wie containerisierte Workloads auf AWS mit ECS Fargate betrieben werden. Ziel ist ein vollständig Terraform-verwalteter PoC, bei dem ein Container über einen Application Load Balancer öffentlich erreichbar ist – ohne EC2-Instanzen zu verwalten.

## Architektur

![Architektur](architecture.svg)

```
Internet
   │ HTTPS
   ▼
Application Load Balancer          (public subnets, spans AZ 1 + AZ 2)
   │
   ▼
ECS Fargate Service
   ├── Fargate Task  (private subnet, AZ 1 – eu-central-1a)
   └── Fargate Task  (private subnet, AZ 2 – eu-central-1b)
         │
         ▼ outbound via NAT Gateway
   ECR · CloudWatch Logs
```

Der Terraform-Code erstellt folgende Ressourcen:

- **VPC** mit je zwei öffentlichen und privaten Subnetzen in `eu-central-1a` und `eu-central-1b`
- **NAT Gateway** pro AZ für AZ-unabhängigen Outbound-Traffic
- **Application Load Balancer** in den öffentlichen Subnetzen, leitet Traffic an die Fargate Tasks weiter
- **ECS Cluster + Fargate Service** mit `desired_count = 2`, einem Task pro AZ
- **Task Definition** mit automatisch erstellter IAM Task Execution Role (ECR Pull + CloudWatch Logs)
- **ECR Repository** für Container Images
- **CloudWatch Log Group** `/ecs/fargate-task` mit 30 Tagen Retention
- **Security Groups** – ALB erlaubt HTTP von `0.0.0.0/0`, Tasks erlauben Inbound nur von der ALB SG

Alle Ressourcen werden mit den offiziellen [Terraform AWS Modules](https://registry.terraform.io/namespaces/terraform-aws-modules) erstellt.

## Voraussetzungen

- [Terraform](https://developer.hashicorp.com/terraform/install) (Version >= 1.2)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Konfigurierter AWS-Account (`aws configure`)

## Konfiguration

Die Variablen ohne Default-Wert müssen in einer `terraform.auto.tfvars` gesetzt werden:

```hcl
region          = "eu-central-1"
vpc_cidr        = "10.0.0.0/16"
container_image = "nginx:latest"   # Platzhalter – später ECR URL
tags = {
  environment = "dev"
  managedBy   = "terraform"
}
```

| Variable          | Beschreibung                              | Default  |
|-------------------|-------------------------------------------|----------|
| `region`          | AWS Region                                | –        |
| `vpc_cidr`        | CIDR-Block der VPC                        | –        |
| `container_image` | Container Image URI                       | –        |
| `container_port`  | Port des Containers                       | `8000`   |
| `task_cpu`        | vCPU Units (256 = 0.25 vCPU)             | `256`    |
| `task_memory`     | Memory in MB                              | `512`    |
| `desired_count`   | Anzahl Fargate Tasks                      | `2`      |
| `tags`            | Tags für alle Ressourcen                  | –        |

## Benutzung

**1. Initialisieren:**
```sh
cd 02-ecs-fargate
terraform init
```

**2. Planen:**
```sh
terraform plan
```

**3. Anwenden:**
```sh
terraform apply
```

**4. Testen:**
```sh
curl http://$(terraform output -raw alb_dns_name)/
```

**5. Zerstören:**
```sh
terraform destroy
```

> ⚠️ Kosten: Zwei NAT Gateways kosten ca. ~$2/Tag. Nach jedem Test `terraform destroy` ausführen.

## Outputs

| Output               | Beschreibung                                   |
|----------------------|------------------------------------------------|
| `alb_dns_name`       | DNS-Name des ALB – Einstiegspunkt für Requests |
| `ecr_repository_url` | ECR URL für `docker push` aus CI/CD           |
| `ecs_cluster_name`   | Name des ECS Clusters                          |
| `vpc_id`             | VPC ID                                         |
| `private_subnet_ids` | Subnet IDs der privaten Subnetze               |

## Nächste Schritte

- Eigenes Container Image mit `/health` Endpoint bauen und in ECR pushen
- `container_image` in `terraform.auto.tfvars` auf die ECR URL setzen
- GitHub Actions Workflow für automatisches Build → Push → Deploy