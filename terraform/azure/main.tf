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
  source_address_prefix       = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "web_access_rule" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "web_access"
  network_security_group_name = azurerm_network_security_group.my_sg.name
  priority                    = 101
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.my_group.name
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix = "*"
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
  network_security_group_id = azurerm_network_security_group.my_sg.id

  ip_configuration {
    name                          = "myconf"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.my_subnet.id
    public_ip_address_id          = azurerm_public_ip.my_vm_pub_ip.id
  }
}


# Kubernetes cluster
resource "azurerm_kubernetes_cluster" "my_cluster" {
  dns_prefix = "sam"
  location = azurerm_resource_group.my_group.location
  name = "my_cluster"
  resource_group_name = azurerm_resource_group.my_group.name
  agent_pool_profile {
    name = "default"
    vm_size = "Standard_D1_v2"
    count = 3
    os_type = "Linux"
    os_disk_size_gb = 30
  }
  service_principal {
    client_id     = ""
    client_secret = ""
  }
}