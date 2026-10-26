# Homelab Infrastructure

A small, self-hosted environment for learning how to build, deploy, monitor, and recover services.

This repository describes the infrastructure behind a YouTube summarizer application. The app stores its data in PostgreSQL with pgvector and supports browsing history and RAG search. The aim is to keep each layer understandable and increasingly reproducible: network, LXC hosts, services, data, backups, and monitoring.

This is a homelab, not a highly available production platform. Some services are still treated as staging while the infrastructure evolves; the application is currently reachable from the internet.

## Architecture

```text
Operator
Laptop: 192.168.0.71
        |
        v
Proxmox: 192.168.0.25
        |
        +-- 10.0.1.0/24 — edge and administration
        |      +-- Bastion: Nginx and SSH jump host
        |      +-- Alpine LXC routers (VyOS migration planned)
        |
        +-- 10.0.2.0/24 — application services
               +-- App LXC: 10.0.2.21
               +-- PostgreSQL LXC: 10.0.2.22
               +-- Debian LXC: database backup destination
```

The two service subnets are separate `/24` networks within `10.0.0.0/16`, with their own Proxmox bridges and routers. The database is an internal service, not intended to be exposed directly to the internet.

## What’s in the stack

| Area | Technology |
|---|---|
| Virtualization | Proxmox VE and LXC |
| Infrastructure provisioning | Terraform |
| Host configuration | Ansible |
| Application and database deployment | Docker Compose |
| Database | PostgreSQL 17 with pgvector 0.8.7 |
| Deployment triggers | Cloudflare webhooks |
| Backups | Dedicated Debian LXC |
| Monitoring | Uptime Kuma, Prometheus, and Grafana |
| Routing | Alpine LXC routers today; VyOS migration planned |

The tools have separate responsibilities: Terraform describes Proxmox resources, Ansible configures hosts, and Compose describes services. Database contents are managed and backed up separately from infrastructure code.

## Repository layout

```text
.
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   └── bootstrap-*.yml
├── db/
│   ├── compose.yml
│   ├── conf/
│   ├── initdb/
│   └── generate_postgres_passwords.sh
├── docs/
└── infra/
    └── *.tf
```

Terraform state, local `.tfvars` files, environment files, credentials, and database dumps do not belong in Git. Keep local secrets and state protected, and commit example configuration—not real secret values.

## Working with the infrastructure

Terraform changes should be reviewed before they are applied:

```bash
terraform -chdir=infra init
terraform -chdir=infra fmt -check
terraform -chdir=infra validate
terraform -chdir=infra plan
```

Read the plan carefully before applying it. In particular, investigate any change that replaces or destroys an LXC. Stateful services should not be recreated casually.

Before running an Ansible playbook, verify the target inventory:

```bash
ansible-inventory -i ansible/inventory/hosts.yml --graph
```

For example, syntax-check the Alpine bootstrap playbook with:

```bash
ansible-playbook \
  -i ansible/inventory/hosts.yml \
  ansible/bootstrap-alpine-lxc.yml \
  --syntax-check
```

Use the relevant playbook and limit it to the intended host or group when making changes. Test new automation on a disposable LXC before applying it to a stateful service.

## Data and recovery

Infrastructure configuration can be recreated; database contents cannot. PostgreSQL backups are stored separately on a dedicated Debian host. A backup is only useful if it can be restored, so restore testing is part of the operating process—not an optional future feature.

The database uses PostgreSQL 17 and pgvector. Keep the extension available in the database image when restoring a dump that uses vector columns or indexes. Database schema changes should be managed through migrations as the application develops.

## Current focus

- Replace the Alpine LXC routers with VyOS.
- Continue separating application, database, and backup responsibilities.
- Improve deployment and host configuration incrementally with Terraform and Ansible.
- Keep backup and restore procedures documented and tested.
- Expand monitoring and alerting as the services grow.

The goal is not to make a home network imitate a large cloud platform. It is to build a small environment where the important pieces are visible, learnable, and recoverable.
