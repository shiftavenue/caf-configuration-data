data "azurerm_client_config" "core" {}

# Base configuration
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
  library_path   = "${path.module}/configurationdata/es_lib"

  subscription_id_connectivity     = var.subscription_id_connectivity
  subscription_id_management       = var.subscription_id_management
  subscription_id_identity         = var.subscription_id_identity
  configure_connectivity_resources = var.configure_connectivity_resources
  configure_identity_resources     = var.configure_identity_resources
  configure_management_resources   = var.configure_management_resources

  strict_subscription_association = false
  deploy_core_landing_zones       = true
  deploy_connectivity_resources   = false
  deploy_identity_resources       = false
  deploy_management_resources     = true
  disable_telemetry               = true

  custom_landing_zones       = var.custom_landing_zones == null ? {} : var.custom_landing_zones
  archetype_config_overrides = var.archetype_config_overrides == null ? {} : var.archetype_config_overrides
}

# Create landing zones
module "lz_vending" {
  source   = "Azure/lz-vending/azurerm"
  version  = ">=4.0.2"
  location = "westeurope"

  for_each = { for i, sub in var.subscriptions : sub.subscription_display_name => sub }


  disable_telemetry                                 = true
  subscription_register_resource_providers_enabled  = true
  resource_group_creation_enabled                   = true
  umi_enabled                                       = true
  umi_resource_group_creation_enabled               = true
  network_watcher_resource_group_enabled            = true
  virtual_network_enabled                           = false
  umi_resource_group_lock_enabled                   = true
  subscription_management_group_association_enabled = each.value.subscription_management_group_id != null

  # subscription variables
  subscription_billing_scope                            = var.billing_scope
  subscription_id                                       = each.value.subscription_id
  subscription_alias_enabled                            = each.value.subscription_alias_enabled
  subscription_display_name                             = each.value.subscription_display_name
  subscription_alias_name                               = each.value.subscription_alias_name
  subscription_workload                                 = each.value.subscription_workload
  subscription_tags                                     = each.value.subscription_tags
  subscription_management_group_id                      = each.value.subscription_management_group_id
  resource_groups                                       = each.value.resource_groups == null ? {} : each.value.resource_groups
  umi_name                                              = each.value.umi_name
  umi_resource_group_name                               = each.value.umi_resource_group_name
  umi_role_assignments                                  = each.value.umi_role_assignments == null ? {} : each.value.umi_role_assignments
  virtual_networks                                      = each.value.virtual_networks == null ? {} : each.value.virtual_networks
  role_assignment_enabled                               = each.value.role_assignment_enabled
  role_assignments                                      = each.value.role_assignments == null ? {} : each.value.role_assignments
  subscription_register_resource_providers_and_features = each.value.subscription_register_resource_providers_and_features
  umi_resource_group_lock_name                          = each.value.umi_resource_group_lock_name
  umi_federated_credentials_github                      = each.value.umi_federated_credentials_github
}

# Custom modules in action - configure GitHub secrets for User-assigned managed identity
module "gh_actions_secrets" {
  source   = "./modules/github_secret"
  for_each = { for i, lz in var.federated_credentials : "${lz.type}-${lz.display_name}" => lz }

  object_id       = each.value.type == "subscription" ? module.lz_vending[each.key].umi_client_id : module.lz_rg_vending[each.key].umi_client_id
  repo_name       = each.value.project_name
  subscription_id = each.value.type == "subscription" ? module.lz_vending[each.key].subscription_id : module.lz_rg_vending[each.key].subscription_id
  tenant_id       = var.tenant_id
}
