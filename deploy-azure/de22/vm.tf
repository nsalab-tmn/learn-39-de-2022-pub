resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-${var.lab_instance}-${random_string.learn.result}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location_01
  size                            = "Standard_D16s_v3"
  admin_username                  = var.adminuser
  admin_password                  = "PaSsW0rD"
  disable_password_authentication = false
  provision_vm_agent              = true


  allow_extension_operations = true
  computer_name              = "vm-${var.lab_instance}-${random_string.learn.result}"
  network_interface_ids = [
    azurerm_network_interface.vif.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 100
    name                 = "disk-${var.lab_instance}-${random_string.learn.result}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"
  }
  
  custom_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    admin_pass   = "PaSsW0rD",
    student_pass = random_string.learn.result,
    hostname     = "${random_string.learn.result}.${var.dns_root}"
    }
  )
)
}