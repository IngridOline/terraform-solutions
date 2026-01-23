# Terraform lab: Azure VM, Network, Storage and Private DNS

This workspace contains a small Terraform lab demonstrating an Azure Virtual Machine, Virtual Network, Storage Account with private endpoint, and a Private DNS Zone using AVM (Azure Virtual Machine) modules.

Contents
- `main.tf` - root module wiring AVM modules together
- `variables.tf` - input variables used by the root configuration
- `locals.tf` - local values (includes `local.diagnostic_settings` used across modules)
- `terraform.tfvars` - local values used for development (not sensitive)
- `.terraform/modules/...` - downloaded module sources (AVM modules)

Quick purpose
- Create a resource group, virtual network, a single subnet, a virtual machine module, a storage account with a private endpoint, and a private DNS zone.
- Demonstrates dynamic IP addressing using the `ip_addresses` module and enabling diagnostic settings sent to a Log Analytics workspace.

Prerequisites
- Terraform 1.10+ (required by `terraform.tf`)
- Azure CLI (`az`) installed for authentication (recommended for local runs)
- An Azure subscription you can deploy resources into

Authentication (local dev)
1. Interactive (Azure CLI):

```powershell
az login
# optionally set the subscription you want to use
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

2. Service principal (CI / automation): set the following environment variables in your pipeline or session:

```powershell
$env:ARM_CLIENT_ID = "<client-id>"
$env:ARM_CLIENT_SECRET = "<client-secret>"
$env:ARM_TENANT_ID = "<tenant-id>"
$env:ARM_SUBSCRIPTION_ID = "<subscription-id>"
```

Note: Avoid committing secrets to source control.

Key variables you may want to change
- `location` in `variables.tf` — default: `uksouth`.
- `resource_group_name`, `virtual_network_name`, `subnet0_name`, `storage_account_name`, etc. — set in `terraform.tfvars` or override in the CLI.
- `virtual_machine_sku` — the VM size; set this to a SKU available in your target region (example: `Standard_D2s_v4`).
- `subnet0_prefix_key` — which key from `address_prefixes_ordered` to use for `subnet0` (defaults to `a`). Change this if you want a different CIDR assigned by the `ip_addresses` module.

Diagnostics
- A `local.diagnostic_settings` value is defined in `locals.tf` and passed into module inputs which accept diagnostic settings (Log Analytics workspace, virtual network module, storage module, private DNS module). The pattern used is the AVM modules accept a map of diagnostic settings and create the `azurerm_monitor_diagnostic_setting` resources internally.
- If you want subscription (Activity Log) diagnostics, create an `azurerm_monitor_diagnostic_setting` targeting the subscription resource id (`/subscriptions/<id>`).

How to run locally (development)

```powershell
cd C:\Users\Student\terraform-labs
# initialize providers without configuring a backend for quick local validation
terraform init -backend=false
terraform validate
terraform plan
# when ready and authenticated, run apply (this will create resources in your subscription)
terraform apply -auto-approve
```

Notes & Troubleshooting
- Error "subscription ID could not be determined": authenticate with `az login` and/or set `$env:ARM_SUBSCRIPTION_ID` (or set `subscription_id` in the provider block). See "Authentication" above.
- If a module complains about missing diagnostic inputs (or you want to enable diagnostics for more resources), pass `local.diagnostic_settings` into the module's `diagnostic_settings` input (if it supports it) or create a single `azurerm_monitor_diagnostic_setting` targeting the specific resource id.
- Avoid committing secrets (client secrets) into the repo. Use environment variables or CI secret stores.

Useful commands (PowerShell)

```powershell
# show current subscription
az account show --query id -o tsv
# set subscription
az account set --subscription "<subscription-id-or-name>"
# set SP environment vars for current session
$env:ARM_CLIENT_ID = "..."
$env:ARM_CLIENT_SECRET = "..."
$env:ARM_TENANT_ID = "..."
$env:ARM_SUBSCRIPTION_ID = "..."
```

Contact / Next steps
- If you want me to: wire subscription-level Activity Log diagnostics, add more subnets, or run a `terraform plan`/`apply` here, tell me which action to perform and I'll proceed.

License
- This lab uses a number of AVM modules from the Azure samples collection; follow module licenses in `.terraform/modules/*/LICENSE` if you plan to redistribute.
