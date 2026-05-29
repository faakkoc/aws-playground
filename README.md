# AWS & Terraform Playground

Dieses Projekt dient als praktisches Beispiel für den Aufbau einer sicheren und modernen AWS-Netzwerkinfrastruktur mit Terraform.

Das Ziel ist es, eine EC2-Instanz in einem **privaten Subnetz** zu provisionieren, die zwar keinen direkten Zugriff aus dem Internet hat, aber selbst über ein **NAT Gateway** auf das Internet zugreifen kann (z.B. für System-Updates).

Der Zugriff auf die private Instanz erfolgt sicher über den **AWS Systems Manager (SSM) Session Manager**, wodurch keine SSH-Keys oder offene Ports benötigt werden.

## Architektur

Der Terraform-Code in diesem Projekt erstellt die folgenden Ressourcen:

- **VPC**: Ein isoliertes, privates Netzwerk in der AWS Cloud.
- **Zwei Subnetze**:
  - Ein **öffentliches Subnetz**, das ein NAT Gateway und den Internet-Traffic-Router enthält.
  - Ein **privates Subnetz**, in dem die EC2-Instanz sicher untergebracht ist.
- **NAT Gateway**: Ermöglicht ausgehenden Internetverkehr für Ressourcen in den privaten Subnetzen.
- **Internet Gateway**: Verbindet die VPC mit dem Internet.
- **Routing-Tabellen**: Leiten den Verkehr korrekt zwischen den Subnetzen und den Gateways.
- **EC2-Instanz**: Eine `t3.micro` Instanz mit Ubuntu 22.04, die im privaten Subnetz läuft.
- **IAM Rolle & SSM**: Eine IAM-Rolle wird der EC2-Instanz zugewiesen, um eine sichere Verbindung über den SSM Session Manager zu ermöglichen.

Alle Ressourcen werden mithilfe der offiziellen [Terraform AWS Modules](https://registry.terraform.io/namespaces/terraform-aws-modules) erstellt.

## Voraussetzungen

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (Version >= 1.2)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Ein konfigurierter AWS-Account (`aws configure`)

## Benutzung

1.  **Initialisieren:**
    Navigiere in den `terraform`-Ordner und lade die notwendigen Provider und Module herunter.
    ```sh
    cd terraform
    terraform init
    ```

2.  **Planen:**
    Überprüfe, welche Ressourcen Terraform erstellen oder ändern wird.
    ```sh
    terraform plan
    ```

3.  **Anwenden:**
    Erstelle die Infrastruktur.
    ```sh
    terraform apply
    ```

4.  **Verbinden:**
    Nachdem die Infrastruktur erstellt wurde, kannst du dich über den AWS Systems Manager Session Manager mit der Instanz verbinden. Dies kann über die AWS-Konsole (EC2 -> Instanz auswählen -> "Connect") oder die AWS CLI erfolgen.

5.  **Zerstören:**
    Entferne alle erstellten Ressourcen, um Kosten zu vermeiden.
    ```sh
    terraform destroy
    ```
