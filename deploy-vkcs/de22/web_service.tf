data "external" "web_service_availability" {
  program = ["/bin/bash", "${path.module}/web_keepalive_provider.sh"]

  query = {
    #url         = "http://${vkcs_compute_instance.compute[0].access_ip_v4}"
    url         = "https://${azurerm_dns_a_record.a_record.name}.${azurerm_dns_a_record.a_record.zone_name}"
    filter      = "200 OK"
    counter     = 200
    sleep       = 5
    prefix      = random_string.learn.result
  }

  depends_on = [
      resource.vkcs_compute_instance.compute
  ]

}