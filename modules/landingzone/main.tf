data "azurerm_client_config" "core" {}

# Targeting: Declare the Azure landing zones Terraform module
# and provide a base configuration.
module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "~>5.0.0"

  default_location = var.default_location

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
    azurerm.identity     = azurerm.identity
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name
  library_path   = "${path.module}/../configurationdata/es_lib"

  subscription_id_connectivity     = local.subscriptions.connectivity
  subscription_id_management       = local.subscriptions.management
  subscription_id_identity         = local.subscriptions.identity
  configure_connectivity_resources = local.network_config
  configure_identity_resources     = local.identity_config
  configure_management_resources   = local.management_config

  strict_subscription_association = false
  deploy_core_landing_zones       = true
  deploy_connectivity_resources   = true
  deploy_identity_resources       = true
  deploy_management_resources     = true
  disable_telemetry               = true

  custom_landing_zones = yamldecode(templatefile("${path.module}/../configurationdata/${var.root_id}/nonstandard-management-groups.yml", {
    rootid = var.root_id
  }))
}

# Create landing zones
module "lz_vending" {
  source   = "Azure/lz-vending/azurerm"
  version  = "~>3.4.1"
  location = "westeurope"

  for_each = {
    for sub in flatten([
      for lz in fileset(path.module, "/../configurationdata/${var.root_id}/applicationlandingzones/*.y*ml") : [
        for sub in yamldecode(templatefile(lz, {
          vnet     = local.hub_networks_by_location["westeurope"].id
          vnetname = local.hub_networks_by_location["westeurope"].name
          }))["subscriptions"] : {
          subscription = sub
          id           = sub.id
          name         = sub.display_name
          tags         = yamldecode(file(lz)).tags
          description  = yamldecode(file(lz)).description
        }
      ]
    ]) : sub.name => sub
  }

  # subscription variables
  subscription_id            = each.value.subscription.id
  subscription_alias_enabled = each.value.subscription.id == null
  subscription_billing_scope = var.billing_scope
  subscription_display_name  = each.value.subscription.display_name
  subscription_alias_name    = each.value.subscription.alias_name
  subscription_workload      = each.value.subscription.workload
  subscription_tags          = each.value.tags
  disable_telemetry          = true

  subscription_management_group_association_enabled = each.value.subscription.managementgroup_id != null ? true : false
  subscription_management_group_id                  = each.value.subscription.managementgroup_id

  resource_group_creation_enabled = true

  umi_enabled                         = true
  umi_resource_group_creation_enabled = true
  umi_name                            = "umi-${lower(each.value.subscription.display_name)}"
  umi_resource_group_name             = "rg-umi-${lower(each.value.subscription.display_name)}"

  network_watcher_resource_group_enabled = true

  # virtual network variables
  virtual_network_enabled = true
  virtual_networks        = each.value.subscription.networks

  role_assignment_enabled = each.value.subscription.role_assignment_enabled
  role_assignments        = each.value.subscription.role_assignments
}
