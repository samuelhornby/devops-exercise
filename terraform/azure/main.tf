##################################################
### This TF file sets up an VMs for Azure        #
##################################################

provider "azurerm" {
  version = "=1.28.0"
}

# Create resource group
resource "azurerm_resource_group" "my_group" {
  location = "West US"
  name     = "test"
}

# Networking
resource "azurerm_virtual_network" "my_net" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_group.location
  name                = "test_net"
  resource_group_name = azurerm_resource_group.my_group.name
}

resource "azurerm_subnet" "my_subnet" {
  address_prefix       = "10.0.2.0/24"
  name                 = "my_sub"
  resource_group_name  = azurerm_resource_group.my_group.name
  virtual_network_name = azurerm_virtual_network.my_net.name
}

resource "azurerm_network_security_group" "my_sg" {
  location            = azurerm_resource_group.my_group.location
  name                = "my_sg1"
  resource_group_name = azurerm_resource_group.my_group.name
}

resource "azurerm_network_security_rule" "ssh_rule" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ssh_access"
  network_security_group_name = azurerm_network_security_group.my_sg.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.my_group.name
  source_port_range           = "*"
  destination_port_range      = "22"
}

resource "azurerm_public_ip" "my_vm_pub_ip" {
  location            = azurerm_resource_group.my_group.location
  name                = "vm_pub_ip"
  resource_group_name = azurerm_resource_group.my_group.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "my_nic" {
  location            = azurerm_resource_group.my_group.location
  name                = "my_nic"
  resource_group_name = azurerm_resource_group.my_group.name

  ip_configuration {
    name                          = "myconf"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.my_subnet.id
    public_ip_address_id          = azurerm_public_ip.my_vm_pub_ip.id
  }
}


# Virtual machines
resource "azurerm_virtual_machine" "my_vm" {
  location                         = azurerm_resource_group.my_group.location
  name                             = "my_vm"
  network_interface_ids            = [azurerm_network_interface.my_nic.id]
  resource_group_name              = azurerm_resource_group.my_group.name
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    create_option     = "FromImage"
    name              = "my_os_disk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    admin_username = "sam"
    computer_name  = "bigdaddyv"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("/home/sam/.ssh/id_rsa.pub")
      path     = "/home/sam/.ssh/authorized_keys"
    }
  }
}