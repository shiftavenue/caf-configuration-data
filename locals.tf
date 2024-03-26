
locals {
  hub_networks_by_location = {
    for i, v in module.enterprise_scale.azurerm_virtual_network.connectivity :
    v.location => v
  }

  connectivity_resource_groups = {
    for i, v in module.enterprise_scale.azurerm_resource_group.connectivity :
    v.name => v
  }

  assignable_custom_role_definitions = {
    for i, v in module.enterprise_scale.azurerm_role_definition.enterprise_scale :
    i => v.role_definition_resource_id
  }
}
