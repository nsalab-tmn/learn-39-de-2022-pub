# resource "azurerm_dns_zone" "comp-hz" {
#   name                = "${var.lab_instance}.az.skillscloud.company"
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_dns_ns_record" "parrent_record" {
#   name                = "${var.lab_instance}"
#   zone_name           = "az.skillscloud.company"
#   resource_group_name = azurerm_resource_group.main.name
#   ttl                 = 300

#   records = azurerm_dns_zone.comp-hz.name_servers
# }

resource "azurerm_dns_a_record" "a_record" {
  name                = "${random_string.learn.result}"
  zone_name           = "az.skillscloud.company"
  resource_group_name = "nsalab-prod"
  ttl                 = 300
  records             = [azurerm_public_ip.pip.ip_address]
}