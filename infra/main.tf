resource "azurerm_resource_group" "aks" {
  location = "uksouth"
  name     = "rg-aks-${var.azure_suffix}"
}
