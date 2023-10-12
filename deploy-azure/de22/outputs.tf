output "URL" {
  value       = "https://${azurerm_dns_a_record.a_record.name}.${azurerm_dns_a_record.a_record.zone_name}"
  description = "Main portal address"
  depends_on  = []
}

output "learn_user" {
  value       =  "student"
  #value       =  selectel_vpc_user_v2.user.name
  description = "Main User"
  depends_on  = []
}

output "learn_password" {
  value       = random_string.learn.result
  description = "Main Password"
  sensitive = false
  depends_on  = []
}

output "pnet_address_global" {
  value       = "${azurerm_dns_a_record.a_record.name}.${azurerm_dns_a_record.a_record.zone_name}"
  description = "pnet global"
  depends_on  = []
}

output "pnet_address" {
  value       = "127.0.0.1"
  description = "pnet local"
  depends_on  = []
}

output "adminuser" {
  value       = var.adminuser
  description = "admin user"
  depends_on  = []
}

output "pnetpassword" {
  value       = var.pnetpassword
  description = "pnet password"
  depends_on  = []
}

output "linuxuser" {
  value       = var.linuxuser
  description = "linux user"
  depends_on  = []
}

output "winuser" {
  value       = var.winuser
  description = "win user"
  depends_on  = []
}

output "winpassword" {
  value       = var.winpassword
  description = "win password"
  depends_on  = []
}

