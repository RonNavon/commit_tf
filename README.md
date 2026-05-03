# Minimal-cost end-to-end HTTPS GCP architecture (Terraform)

A single-zone, demo-grade implementation of:

```
External user
   │  HTTPS:443
   ▼
Cloud Armor + External HTTPS LB     [Project A | VPC A]
   │  HTTPS:443  (Google-managed cert)
   ▼
Private Service Connect (PSC NEG → service attachment)
   │
   ▼
Internal HTTPS LB                   [Project B | VPC B]
   │  HTTPS:443  (regional self-managed cert)
   ▼
GKE pod — nginx:alpine listening on :443 with TLS
```

**HTTPS on every hop. No port 80 listener anywhere.** TLS terminates at the external LB, again at the internal LB, and finally inside the pod's nginx — all on port 443. Each leg is re-encrypted because every `backend_service.protocol = HTTPS` and every health check is HTTPS.

The "app" is a simple **hello-world**: a single `nginx:alpine` container with a 12-line config that returns `Hello, World!` over HTTPS. The container image is plain, well-known nginx; the customization (TLS + the hello message) is pushed into a `ConfigMap` so the workload stays one container, no sidecar, no custom build.

---

## Repository layout

```
modules/                             # one resource per module
├── vpc/  subnet/  firewall_rule/  router/  nat/
├── gke_cluster/  gke_node_pool/
├── k8s_deployment/  k8s_service/  k8s_ingress/
├── ssl_certificate/  backend_service/  url_map/
├── target_https_proxy/  forwarding_rule/
├── health_check/  network_endpoint_group/  psc_neg/
├── cloud_armor_policy/
└── psc_service_attachment/  psc_endpoint/

envs/
├── project_a/                       # Cloud Armor + External HTTPS LB + PSC consumer
└── project_b/                       # GKE + Internal HTTPS LB + PSC producer

k8s/                                 # reference manifests
```

Every module follows the same shape (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`) and creates exactly one resource.

---

## What's deployed

### Project B (producer)

* **VPC + 3 subnets**: GKE (`/24` with `pods` and `services` secondaries), proxy-only (`REGIONAL_MANAGED_PROXY`), PSC NAT (`PRIVATE_SERVICE_CONNECT`).
* **Two firewall rules**: allow LB+health-check probers, allow east-west.
* **No Cloud NAT / Cloud Router** by default (toggle with `enable_private_nodes`).
* **Zonal GKE** in `us-central1-a`, 1 × `e2-small` Spot node.
* **Workload**: namespace, K8s Secret with a self-signed TLS cert, ConfigMap with the nginx HTTPS config, single-container `nginx:alpine` Deployment listening on 443, ClusterIP Service annotated with `cloud.google.com/neg`.
* **Internal HTTPS LB** built primitive-by-primitive: HTTPS health check → backend service (HTTPS, NEG-backed) → URL map → target HTTPS proxy (regional self-managed cert) → forwarding rule (`INTERNAL_MANAGED`, port 443).
* **PSC service attachment** publishing the internal forwarding rule.

### Project A (consumer / edge)

* **Tiny VPC** with a `/28` consumer subnet.
* **PSC consumer endpoint** (private internal IP) — handy for in-VPC debugging.
* **PSC NEG** (regional, `network_endpoint_type = PRIVATE_SERVICE_CONNECT`) — the bridge from the global external LB into the producer VPC.
* **External HTTPS LB**: HTTPS health check → backend service (HTTPS, Cloud Armor attached) → URL map → target HTTPS proxy (Google-managed cert) → forwarding rule (`EXTERNAL_MANAGED`, port 443) on a reserved global static IP.
* **Cloud Armor**: default allow + adaptive protection only.

---

## What was simplified (vs. a production build)

| Area | What we did | Why it's cheaper |
| --- | --- | --- |
| Region/zone | Single zone `us-central1-a` | No cross-zone egress, no regional cluster overhead |
| GKE | Zonal cluster, 1 node pool, `node_count = 1`, `e2-small`, **Spot** VMs, 20 GB `pd-standard`, autoscaling **off** | Spot ≈ 60–91% off normal price; smallest viable machine; smallest viable disk |
| Network | Public GKE nodes by default → **no Cloud NAT, no Cloud Router** | Cloud NAT is metered per VM-hour; skipping it removes the gateway cost outright |
| Firewall | Two rules: LB+health check, internal east-west | Defaults are deny-all ingress; we add only what's needed |
| Workload | Single nginx container with a tiny ConfigMap, no sidecar, no Flask layer | One container, no extra resources |
| Pod TLS | Single self-signed cert reused for both pod and Internal LB | One `tls_self_signed_cert` resource instead of two |
| Cloud Armor | Default allow + adaptive protection only — no WAF, no geo blocks | Each preconfigured WAF rule is metered separately |
| Logging / Monitoring | GKE defaults only, no upgrades | Cloud Logging / Monitoring "system" tier only |
| Cluster control plane | Public endpoint (private nodes off by default) | Avoids the master peering + Cloud NAT requirement |
| Network policy / Calico | Disabled | Less node CPU; demo doesn't need it |
| Outputs | Only the four essentials | No redundant noise |

If you want the production look back, flip the toggles:

* `enable_private_nodes = true` → re-enables Cloud NAT + Cloud Router.
* `gke_use_spot = false` → on-demand nodes.
* Add `custom_rules` / `preconfigured_waf_rules` to `module.cloud_armor`.

---

## TLS flow

```
Client ─HTTPS:443─►  External LB             (Google-managed cert)
                          │  TLS terminated, then re-encrypted
                          ▼
External LB ─HTTPS:443─►  PSC NEG  ─►  Service Attachment
                                                │
                                                ▼
PSC ─►  Internal LB                        (regional self-managed cert)
                          │  TLS terminated, then re-encrypted
                          ▼
Internal LB ─HTTPS:443─►  Pod NEG  ─►  nginx :443
                                                │  TLS terminated
                                                ▼
                                        nginx returns "Hello, World!"
```

Three TLS terminations in a row, every link encrypted. There is **no port-80 listener** anywhere in this stack — no `target_http_proxy`, no `:80` forwarding rule, no `:80` containerPort, no firewall opening for 80.

---

## Deployment

### 0. Prerequisites

* Two GCP projects (Project A + Project B), both with billing enabled.
* APIs in both: `compute.googleapis.com`, `container.googleapis.com`, `iam.googleapis.com`.
* Caller has `roles/compute.networkAdmin`, `roles/compute.securityAdmin`, `roles/container.admin`, `roles/iam.serviceAccountAdmin`.
* Terraform `>= 1.6.0`, Google provider `>= 6.0.0`.

### 1. Apply Project B (producer)

```bash
cd envs/project_b
cp terraform.tfvars.example terraform.tfvars
# Edit: set project_id

terraform init
terraform apply
```

Capture the `service_attachment_self_link` output for step 2.

> The `kubernetes` provider authenticates against the GKE control plane on each plan/apply. With the public-endpoint default, no VPN/peering is needed. On a fresh state you may need `terraform apply -target=module.gke_node_pool` first.

### 2. Apply Project A (edge)

```bash
cd ../project_a
cp terraform.tfvars.example terraform.tfvars
# Edit: project_id, external_lb_domains, producer_service_attachment

terraform init
terraform apply
```

### 3. Publish DNS

`A` record on every domain in `external_lb_domains` → `external_lb_ip` from the apply output. The Google-managed cert provisions a few minutes after DNS propagates.

### 4. Verify

```bash
curl -v https://app.example.com/                  # should return "Hello, World!"
curl -k -v https://<psc_endpoint_ip>/             # tests the internal LB directly from inside Project A's VPC
```

### 5. Tear down (reverse)

```bash
cd envs/project_a && terraform destroy
cd ../project_b  && terraform destroy
```

---

## Outputs

```
project_b:
  gke_cluster_name             = "commit-gke"
  internal_lb_ip               = "10.20.0.x"
  service_attachment_self_link = "projects/.../serviceAttachments/commit-psc-sa"

project_a:
  external_lb_ip               = "34.x.x.x"
  psc_endpoint_ip              = "10.10.0.x"
```

---

## Rough monthly cost (us-central1, very approximate)

| Resource | Estimate |
| --- | --- |
| GKE management fee, zonal | $0 (one zonal cluster per billing account is free) |
| 1× e2-small Spot node, 730 h | ≈ $3 |
| 20 GB pd-standard | ≈ $1 |
| Cloud Armor policy (no WAF rules) | ≈ $5 (per-policy) |
| External HTTPS LB forwarding rule | ≈ $18 |
| Internal HTTPS LB forwarding rule | ≈ $18 |
| Egress / data processing | usage-based, near $0 for a demo |
| **Total** | **≈ $45 / month** |

The two L7 LBs are the cost driver. To make this even cheaper, you'd have to drop one of them — but then either the PSC bridge or the public ingress goes away. For a demo that exercises the full architecture (Cloud Armor → External LB → PSC → Internal LB → GKE), this is the floor.
