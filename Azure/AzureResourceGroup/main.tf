# Azure Resource Group
resource "azurerm_resource_group" "azure_rg" {
  name     = "${var.common_prefix}RG"
  location = var.location
  tags = {
    Environment = "Sandbox"
  }
}