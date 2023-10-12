variable "linuxuser" {
  default = "root"
  type = string
}

variable "pnet_address" {
  default = "127.0.0.1"
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

variable "adminuser" {
  default = "azadmin"
  type = string
}

variable "pnetpassword" {
  default = "PaSsW0rD"
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

variable "pnetuser" {
    type        = string
    default     = "azadmin"
}
