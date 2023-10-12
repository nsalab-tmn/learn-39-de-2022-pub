terraform {
  required_providers {
    vkcs = {
      source = "vk-cs/vkcs"
    }
  }
}

provider "vkcs" {
  username   = "username"
  password   = "password"
  project_id = "id"
  region     = "RegionOne"
}

provider "azurerm" {
  features {}

  subscription_id = ""
  tenant_id       = ""
}