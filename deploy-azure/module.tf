module "de22" {
    source = "./de22"
    count = 1
    
    tp_learn_env = "${var.tp_learn_env}"
    tp_learn_user = "${var.tp_learn_user}"    
}

output "URL" {
  value =  module.de22[0].URL 
  description = "Main portal address"
}

output "learn_password" {
  value =  module.de22[0].learn_password 
  description = "Main Password"  
}

output "learn_user" {
  value =  module.de22[0].learn_user 
  description = "Main User"
}

output "pnet_address_global" {
  value       = module.de22[0].pnet_address_global 
  description = "Main portal address"
}

output "pnet_address" {
  value       = var.pnet_address
}

output "adminuser" {
  value       = var.adminuser
}

output "pnetpassword" {
  value       = var.pnetpassword
  description = "pnet password"
}

output "linuxuser" {
  value       = var.linuxuser
  description = "linux user"
}

output "linuxpassword" {
  value       = var.linuxpassword
  description = "linux password"
}

output "winuser" {
  value       = var.winuser
  description = "win user"
}

output "winpassword" {
  value       = var.winpassword
  description = "win password"
}
    
output "pnetuser" {
  value       = var.pnetuser
  description = "pnetuser"
}
