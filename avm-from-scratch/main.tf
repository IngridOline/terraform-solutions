module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}

module "ip_addresses" {
  source           = "Azure/avm-utl-network-ip-addresses/azurerm"
  version          = "0.1.0"
  address_space    = var.address_space
  address_prefixes = var.address_prefixes_ordered
}

module "avm-res-network-virtualnetwork" {
  source           = "Azure/avm-res-network-virtualnetwork/azurerm"
  version          = "0.17.1"
  location         = var.location
  parent_id        = module.resource_group.resource_id
  address_space    = [var.address_space]
  enable_telemetry = true
  name             = var.virtual_network_name
  subnets = {
    subnet0 = {
      name                            = var.subnet0_name
      default_outbound_access_enabled = false
      address_prefixes                = [module.ip_addresses.address_prefixes["f"]]
    }
  }
  tags                = var.tags
  diagnostic_settings = local.diagnostic_settings
}

module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.4.0"

  domain_name = "privatelink.blob.core.windows.net"
  parent_id   = module.resource_group.resource_id
  virtual_network_links = {
    vnetlink1 = {
      name   = "storage-account"
      vnetid = module.avm-res-network-virtualnetwork.resource_id
    }
  }
  tags = var.tags
}

module "avm-res-storage-storageaccount" {
  source              = "Azure/avm-res-storage-storageaccount/azurerm"
  version             = "0.6.7"
  location            = var.location
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  containers = {
    demo = {
      name = "demo"
    }
  }
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
      subnet_resource_id            = module.avm-res-network-virtualnetwork.subnets.subnet0.resource_id
      subresource_name              = "blob"
    }
  }
  diagnostic_settings_blob            = local.diagnostic_settings
  diagnostic_settings_file            = local.diagnostic_settings
  diagnostic_settings_queue           = local.diagnostic_settings
  diagnostic_settings_storage_account = local.diagnostic_settings
  diagnostic_settings_table           = local.diagnostic_settings
  tags                                = var.tags
}

module "log_analytics_workspace" {
  source              = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version             = "0.5.1"
  name                = var.log_analytics_workspace_name
  resource_group_name = module.resource_group.name
  location            = var.location
  diagnostic_settings = local.diagnostic_settings
}
