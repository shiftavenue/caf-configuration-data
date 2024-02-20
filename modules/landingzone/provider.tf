terraform {
  required_providers {
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = local.subscriptions.connectivity
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = local.subscriptions.management
  features {}
}

provider "azurerm" {
  alias           = "identity"
  subscription_id = local.subscriptions.identity
  features {}
}
