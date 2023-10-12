

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.lab_instance}-${random_string.learn.result}"
  location = var.location_01
  tags     = {
    Environment: "${var.tp_learn_env}"
    Owner: "${var.tp_learn_user}"
  }
}

resource "random_string" "learn" {
  length           = 8
  special          = false
  min_lower        = 2
  min_numeric      = 2
  upper            = false
}

resource "random_string" "pass" {
  length           = 16
  special          = false
  min_lower        = 2
  min_numeric      = 2
  min_upper        = 2
  min_special      = 1
  override_special = "+-=%#^@"
}
