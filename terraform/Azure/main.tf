# Author: Subhayan Dasgupta
# Date of modification: 06/12/2023

# Terraform provider: Azure Resource Manager (azurerm)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.83.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Azure Resource Group module
module "AzureResourceGroup" {
  source        = "./AzureResourceGroup"
  common_prefix = "PwCsPoC"
  location      = "Central India"
}

# Azure Virtual Machine module
module "azure_vm" {
  source        = "./AzureVirtualMachine"
  common_prefix = "PwCsPoC"
  rg_name       = module.AzureResourceGroup.rg_name_out
  rg_location   = "Central India"
}
