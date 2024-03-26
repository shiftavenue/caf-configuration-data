terraform {
  backend "azurerm" {
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.42"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.subscription_id_connectivity
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.subscription_id_management
  features {}
}

provider "azurerm" {
  alias           = "identity"
  subscription_id = var.subscription_id_identity
  features {}
}

provider "github" {
  token = var.token
}
