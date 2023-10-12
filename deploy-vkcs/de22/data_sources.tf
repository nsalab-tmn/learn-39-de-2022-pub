data "vkcs_compute_keypair" "kp" {
  name = "kp"
}

data "vkcs_compute_flavor" "flavor" {
  name = "NESTED-4-8"
}

data "vkcs_networking_network" "extnet" {
  name = "ext-net"
}

data "vkcs_images_image" "ubuntu" {
  name        = "Ubuntu-18.04-202003"
  most_recent = true

  properties = {
    key = "value"
  }
}