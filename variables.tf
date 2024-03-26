variable "token" {
  type        = string
  description = "GitHub access token to use for the deployment."
}

variable "default_location" {
  type        = string
  default     = "westeurope"
  description = "Default location for resources."
}

variable "root_id" {
  type        = string
  description = "Root ID that is part of all resources and can be used to discern environments."
}

variable "root_name" {
  type        = string
  description = "Name of the root management group."
}

# az billing account list --expand "billingProfiles,billingProfiles/invoiceSections"
variable "billing_scope" {
  type        = string
  default     = ""
  description = "The billing scope to use for the subscription vending module. Not required if subscriptions are created beforehand. Format: /providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456"
}

variable "custom_landing_zones" {
  description = "Custom landing zone architecture aside from standards."
  default     = {}
  type = map(
    object({
      display_name               = string
      parent_management_group_id = string
      subscription_ids           = list(string)
      archetype_config = object({
        archetype_id   = string
        parameters     = map(any)
        access_control = map(list(string))
      })
    })
  )
}

variable "tenant_id" {
  type        = string
  description = "The Entra tenant ID to use for the deployment."
  default     = "ff01e8b8-4388-4511-a60e-5efc1401b87e"
}

variable "subscription_id_connectivity" {
  type        = string
  description = "The subscription ID to use for the connectivity subscription. Not required if the connectivity subscription is not deployed."
  default     = "13f8e7e8-07ec-4fa0-8f16-ed744a33ac04"
}
variable "subscription_id_management" {
  type        = string
  description = "The subscription ID to use for the management subscription. Not required if the management subscription is not deployed."
  default     = "13f8e7e8-07ec-4fa0-8f16-ed744a33ac04"
}
variable "subscription_id_identity" {
  type        = string
  description = "The subscription ID to use for the identity subscription. Not required if the identity subscription is not deployed."
  default     = "13f8e7e8-07ec-4fa0-8f16-ed744a33ac04"
}

variable "configure_management_resources" {
  type = object({
    settings = optional(object({
      log_analytics = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          retention_in_days                                 = optional(number, 30)
          enable_monitoring_for_vm                          = optional(bool, true)
          enable_monitoring_for_vmss                        = optional(bool, true)
          enable_solution_for_agent_health_assessment       = optional(bool, true)
          enable_solution_for_anti_malware                  = optional(bool, true)
          enable_solution_for_change_tracking               = optional(bool, true)
          enable_solution_for_service_map                   = optional(bool, false)
          enable_solution_for_sql_assessment                = optional(bool, true)
          enable_solution_for_sql_vulnerability_assessment  = optional(bool, true)
          enable_solution_for_sql_advanced_threat_detection = optional(bool, true)
          enable_solution_for_updates                       = optional(bool, true)
          enable_solution_for_vm_insights                   = optional(bool, true)
          enable_solution_for_container_insights            = optional(bool, true)
          enable_sentinel                                   = optional(bool, true)
        }), {})
      }), {})
      security_center = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          email_security_contact                                = optional(string, "security_contact@replace_me")
          enable_defender_for_apis                              = optional(bool, true)
          enable_defender_for_app_services                      = optional(bool, true)
          enable_defender_for_arm                               = optional(bool, true)
          enable_defender_for_containers                        = optional(bool, true)
          enable_defender_for_cosmosdbs                         = optional(bool, true)
          enable_defender_for_cspm                              = optional(bool, true)
          enable_defender_for_dns                               = optional(bool, true)
          enable_defender_for_key_vault                         = optional(bool, true)
          enable_defender_for_oss_databases                     = optional(bool, true)
          enable_defender_for_servers                           = optional(bool, true)
          enable_defender_for_servers_vulnerability_assessments = optional(bool, true)
          enable_defender_for_sql_servers                       = optional(bool, true)
          enable_defender_for_sql_server_vms                    = optional(bool, true)
          enable_defender_for_storage                           = optional(bool, true)
        }), {})
      }), {})
    }), {})
    location = optional(string, "")
    tags     = optional(any, {})
    advanced = optional(any, {})
  })
  description = "If specified, will customize the \"Management\" landing zone settings and resources."
  default     = {}
}
variable "configure_identity_resources" {
  type = object({
    settings = optional(object({
      identity = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          enable_deny_public_ip             = optional(bool, true)
          enable_deny_rdp_from_internet     = optional(bool, true)
          enable_deny_subnet_without_nsg    = optional(bool, true)
          enable_deploy_azure_backup_on_vms = optional(bool, true)
        }), {})
      }), {})
    }), {})
  })
  description = "If specified, will customize the \"Identity\" landing zone settings."
  default     = {}
}
variable "configure_connectivity_resources" {
  type = object({
    settings = optional(object({
      hub_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_space                = list(string)
            location                     = optional(string, "")
            link_to_ddos_protection_plan = optional(bool, false)
            dns_servers                  = optional(list(string), [])
            bgp_community                = optional(string, "")
            subnets = optional(list(
              object({
                name                      = string
                address_prefixes          = list(string)
                network_security_group_id = optional(string, "")
                route_table_id            = optional(string, "")
              })
            ), [])
            virtual_network_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                address_prefix           = optional(string, "")
                gateway_sku_expressroute = optional(string, "")
                gateway_sku_vpn          = optional(string, "")
                advanced_vpn_settings = optional(object({
                  enable_bgp                       = optional(bool, null)
                  active_active                    = optional(bool, null)
                  private_ip_address_allocation    = optional(string, "")
                  default_local_network_gateway_id = optional(string, "")
                  vpn_client_configuration = optional(list(
                    object({
                      address_space = list(string)
                      aad_tenant    = optional(string, null)
                      aad_audience  = optional(string, null)
                      aad_issuer    = optional(string, null)
                      root_certificate = optional(list(
                        object({
                          name             = string
                          public_cert_data = string
                        })
                      ), [])
                      revoked_certificate = optional(list(
                        object({
                          name       = string
                          thumbprint = string
                        })
                      ), [])
                      radius_server_address = optional(string, null)
                      radius_server_secret  = optional(string, null)
                      vpn_client_protocols  = optional(list(string), null)
                      vpn_auth_types        = optional(list(string), null)
                    })
                  ), [])
                  bgp_settings = optional(list(
                    object({
                      asn         = optional(number, null)
                      peer_weight = optional(number, null)
                      peering_addresses = optional(list(
                        object({
                          ip_configuration_name = optional(string, null)
                          apipa_addresses       = optional(list(string), null)
                        })
                      ), [])
                    })
                  ), [])
                  custom_route = optional(list(
                    object({
                      address_prefixes = optional(list(string), [])
                    })
                  ), [])
                }), {})
              }), {})
            }), {})
            azure_firewall = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                address_prefix                = optional(string, "")
                address_management_prefix     = optional(string, "")
                enable_dns_proxy              = optional(bool, true)
                dns_servers                   = optional(list(string), [])
                sku_tier                      = optional(string, "Standard")
                base_policy_id                = optional(string, "")
                private_ip_ranges             = optional(list(string), [])
                threat_intelligence_mode      = optional(string, "Alert")
                threat_intelligence_allowlist = optional(list(string), [])
                availability_zones = optional(object({
                  zone_1 = optional(bool, true)
                  zone_2 = optional(bool, true)
                  zone_3 = optional(bool, true)
                }), {})
              }), {})
            }), {})
            spoke_virtual_network_resource_ids      = optional(list(string), [])
            enable_outbound_virtual_network_peering = optional(bool, false)
            enable_hub_network_mesh_peering         = optional(bool, false)
          })
        })
      ), [])
      vwan_hub_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_prefix = string
            location       = string
            sku            = optional(string, "")
            routes = optional(list(
              object({
                address_prefixes    = list(string)
                next_hop_ip_address = string
              })
            ), [])
            routing_intent = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                routing_policies = optional(list(object({
                  name         = string
                  destinations = list(string)
                })), [])
              }), {})
            }), {})
            expressroute_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                scale_unit = optional(number, 1)
              }), {})
            }), {})
            vpn_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                bgp_settings = optional(list(
                  object({
                    asn         = number
                    peer_weight = number
                    instance_0_bgp_peering_address = optional(list(
                      object({
                        custom_ips = list(string)
                      })
                    ), [])
                    instance_1_bgp_peering_address = optional(list(
                      object({
                        custom_ips = list(string)
                      })
                    ), [])
                  })
                ), [])
                routing_preference = optional(string, "Microsoft Network")
                scale_unit         = optional(number, 1)
              }), {})
            }), {})
            azure_firewall = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                enable_dns_proxy              = optional(bool, true)
                dns_servers                   = optional(list(string), [])
                sku_tier                      = optional(string, "Standard")
                base_policy_id                = optional(string, "")
                private_ip_ranges             = optional(list(string), [])
                threat_intelligence_mode      = optional(string, "Alert")
                threat_intelligence_allowlist = optional(list(string), [])
                availability_zones = optional(object({
                  zone_1 = optional(bool, true)
                  zone_2 = optional(bool, true)
                  zone_3 = optional(bool, true)
                }), {})
              }), {})
            }), {})
            spoke_virtual_network_resource_ids        = optional(list(string), [])
            secure_spoke_virtual_network_resource_ids = optional(list(string), [])
            enable_virtual_hub_connections            = optional(bool, false)
          })
        })
      ), [])
      ddos_protection_plan = optional(object({
        enabled = optional(bool, false)
        config = optional(object({
          location = optional(string, "")
        }), {})
      }), {})
      dns = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          location = optional(string, "")
          enable_private_link_by_service = optional(object({
            azure_api_management                 = optional(bool, true)
            azure_app_configuration_stores       = optional(bool, true)
            azure_arc                            = optional(bool, true)
            azure_automation_dscandhybridworker  = optional(bool, true)
            azure_automation_webhook             = optional(bool, true)
            azure_backup                         = optional(bool, true)
            azure_batch_account                  = optional(bool, true)
            azure_bot_service_bot                = optional(bool, true)
            azure_bot_service_token              = optional(bool, true)
            azure_cache_for_redis                = optional(bool, true)
            azure_cache_for_redis_enterprise     = optional(bool, true)
            azure_container_registry             = optional(bool, true)
            azure_cosmos_db_cassandra            = optional(bool, true)
            azure_cosmos_db_gremlin              = optional(bool, true)
            azure_cosmos_db_mongodb              = optional(bool, true)
            azure_cosmos_db_sql                  = optional(bool, true)
            azure_cosmos_db_table                = optional(bool, true)
            azure_data_explorer                  = optional(bool, true)
            azure_data_factory                   = optional(bool, true)
            azure_data_factory_portal            = optional(bool, true)
            azure_data_health_data_services      = optional(bool, true)
            azure_data_lake_file_system_gen2     = optional(bool, true)
            azure_database_for_mariadb_server    = optional(bool, true)
            azure_database_for_mysql_server      = optional(bool, true)
            azure_database_for_postgresql_server = optional(bool, true)
            azure_digital_twins                  = optional(bool, true)
            azure_event_grid_domain              = optional(bool, true)
            azure_event_grid_topic               = optional(bool, true)
            azure_event_hubs_namespace           = optional(bool, true)
            azure_file_sync                      = optional(bool, true)
            azure_hdinsights                     = optional(bool, true)
            azure_iot_dps                        = optional(bool, true)
            azure_iot_hub                        = optional(bool, true)
            azure_key_vault                      = optional(bool, true)
            azure_key_vault_managed_hsm          = optional(bool, true)
            azure_kubernetes_service_management  = optional(bool, true)
            azure_machine_learning_workspace     = optional(bool, true)
            azure_managed_disks                  = optional(bool, true)
            azure_media_services                 = optional(bool, true)
            azure_migrate                        = optional(bool, true)
            azure_monitor                        = optional(bool, true)
            azure_purview_account                = optional(bool, true)
            azure_purview_studio                 = optional(bool, true)
            azure_relay_namespace                = optional(bool, true)
            azure_search_service                 = optional(bool, true)
            azure_service_bus_namespace          = optional(bool, true)
            azure_site_recovery                  = optional(bool, true)
            azure_sql_database_sqlserver         = optional(bool, true)
            azure_synapse_analytics_dev          = optional(bool, true)
            azure_synapse_analytics_sql          = optional(bool, true)
            azure_synapse_studio                 = optional(bool, true)
            azure_web_apps_sites                 = optional(bool, true)
            azure_web_apps_static_sites          = optional(bool, true)
            cognitive_services_account           = optional(bool, true)
            microsoft_power_bi                   = optional(bool, true)
            signalr                              = optional(bool, true)
            signalr_webpubsub                    = optional(bool, true)
            storage_account_blob                 = optional(bool, true)
            storage_account_file                 = optional(bool, true)
            storage_account_queue                = optional(bool, true)
            storage_account_table                = optional(bool, true)
            storage_account_web                  = optional(bool, true)
          }), {})
          private_link_locations                                 = optional(list(string), [])
          public_dns_zones                                       = optional(list(string), [])
          private_dns_zones                                      = optional(list(string), [])
          enable_private_dns_zone_virtual_network_link_on_hubs   = optional(bool, true)
          enable_private_dns_zone_virtual_network_link_on_spokes = optional(bool, true)
          virtual_network_resource_ids_to_link                   = optional(list(string), [])
        }), {})
      }), {})
    }), {})
    location = optional(string, "")
    tags     = optional(any, {})
    advanced = optional(any, {})
  })
  description = <<DESCRIPTION
If specified, will customize the \"Connectivity\" landing zone settings and resources.

Notes for the `configure_connectivity_resources` variable:

- `settings.hub_network_virtual_network_gateway.config.address_prefix`
  - Only support adding a single address prefix for GatewaySubnet subnet
- `settings.hub_network_virtual_network_gateway.config.gateway_sku_expressroute`
  - If specified, will deploy the ExpressRoute gateway into the GatewaySubnet subnet
- `settings.hub_network_virtual_network_gateway.config.gateway_sku_vpn`
  - If specified, will deploy the VPN gateway into the GatewaySubnet subnet
- `settings.hub_network_virtual_network_gateway.config.advanced_vpn_settings.private_ip_address_allocation`
  - Valid options are `""`, `"Static"` or `"Dynamic"`. Will set `private_ip_address_enabled` and `private_ip_address_allocation` as needed.
- `settings.azure_firewall.config.address_prefix`
  - Only support adding a single address prefix for AzureFirewallManagementSubnet subnet
DESCRIPTION
  default     = {}
}

variable "archetype_config_overrides" {
  type = map(
    object({
      archetype_id   = string
      parameters     = map(any)
      access_control = map(list(string))
    })
  )
  description = "If specified, will override the default archetype configuration for the specified archetype."
  default     = {}
}

variable "subscriptions" {
  type = list(object({
    subscription_id                                   = string
    subscription_alias_enabled                        = bool
    subscription_display_name                         = string
    subscription_alias_name                           = string
    subscription_workload                             = string
    subscription_tags                                 = map(string)
    subscription_management_group_association_enabled = optional(bool)
    subscription_management_group_id                  = string
    umi_name                                          = string
    umi_resource_group_name                           = string
    umi_role_assignments = map(object({
      definition     = string
      relative_scope = optional(string, "")
    }))
    resource_groups = map(object({
      name     = string
      location = string
      tags     = map(string)
    }))
    virtual_networks = map(object({
      name                = string
      address_space       = list(string)
      resource_group_name = string

      location = optional(string, "")

      dns_servers = optional(list(string), [])

      ddos_protection_enabled = optional(bool, false)
      ddos_protection_plan_id = optional(string, "")

      hub_network_resource_id         = optional(string, "")
      hub_peering_enabled             = optional(bool, false)
      hub_peering_name_tohub          = optional(string, "")
      hub_peering_name_fromhub        = optional(string, "")
      hub_peering_use_remote_gateways = optional(bool, true)

      mesh_peering_enabled                 = optional(bool, false)
      mesh_peering_allow_forwarded_traffic = optional(bool, false)

      resource_group_creation_enabled = optional(bool, true)
      resource_group_lock_enabled     = optional(bool, true)
      resource_group_lock_name        = optional(string, "")
      resource_group_tags             = optional(map(string), {})

      vwan_associated_routetable_resource_id   = optional(string, "")
      vwan_connection_enabled                  = optional(bool, false)
      vwan_connection_name                     = optional(string, "")
      vwan_hub_resource_id                     = optional(string, "")
      vwan_propagated_routetables_labels       = optional(list(string), [])
      vwan_propagated_routetables_resource_ids = optional(list(string), [])
      vwan_security_configuration = optional(object({
        secure_internet_traffic = optional(bool, false)
        secure_private_traffic  = optional(bool, false)
        routing_intent_enabled  = optional(bool, false)
      }), {})

      tags = optional(map(string), {})
    }))
    role_assignment_enabled = bool
    role_assignments = map(object({
      principal_id      = string,
      definition        = string,
      relative_scope    = optional(string, ""),
      condition         = optional(string, ""),
      condition_version = optional(string, ""),
    }))
    subscription_register_resource_providers_and_features = optional(map(set(string)))
    umi_resource_group_lock_name                          = string
    umi_federated_credentials_github = map(object({
      name         = optional(string, "")
      organization = string
      repository   = string
      entity       = string
      value        = optional(string, "")
    }))
  }))
  description = "Subscriptions, should be auto-generated from configuration data!"

}

variable "federated_credentials" {
  type = list(object({
    display_name = string
    project_name = string
    type         = string
  }))
  description = "Federated credentials for GitHub Actions secrets, should be auto-generated from configuration data!"
  default     = []

  validation {
    error_message = "Type can only be 'subscription' or 'resource_group'"
    condition     = alltrue([for i, v in var.federated_credentials : contains(["subscription", "resource_group"], v.type)])
  }
}
