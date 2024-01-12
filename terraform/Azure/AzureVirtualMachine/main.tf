# Deploying an Azure Linux Virtual Machine

# Azure Virtual Network
resource "azurerm_virtual_network" "azure_vnet" {
  name                = "${var.common_prefix}VNet"
  address_space       = ["10.0.0.0/16"]
  location            = var.rg_location
  resource_group_name = var.rg_name
}

# Azure Virtual Subnet
resource "azurerm_subnet" "azure_subnet" {
  name                 = "${var.common_prefix}Subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Azure Virtual Network Interface Card (NIC)
resource "azurerm_network_interface" "azure_nic" {
  name                = "${var.common_prefix}NIC"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.common_prefix}IP"
    subnet_id                     = azurerm_subnet.azure_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Azure Virtual Machine
resource "azurerm_virtual_machine" "azure_vm" {
  name                  = "${var.common_prefix}VM"
  location              = var.rg_location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.azure_nic.id]
  vm_size               = "Standard_B2s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.common_prefix}K8sTestVM-1"
    admin_username = "testuser"
    admin_password = "#Passwd_12345"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    Environment = "Sandbox"
  }
}