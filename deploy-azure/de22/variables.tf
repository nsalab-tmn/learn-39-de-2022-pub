variable prefix {
  default = "student"
}

variable lab_instance {
  default = "de22"
}

variable "location_01" {
  default = "southcentralus"
  type = string
}

variable "adminuser" {
  default = "azadmin"
  type = string
}

variable "pnetpassword" {
  default = "PaSsW0rD"
  type = string
}

variable dns_root {
  default = "az.skillscloud.company"
}

variable "linuxuser" {
  default = "root"
  type = string
}

variable "linuxpassword" {
  default = "toor"
  type = string
}

variable "winuser" {
  default = "administrator"
  type = string
}

variable "winpassword" {
  default = "P@ssw0rd"
  type = string
}

variable "tp_learn_env" {
    type        = string
    default     = "dev"
}

variable "tp_learn_user" {
    type        = string
    default     = "user01"
}
