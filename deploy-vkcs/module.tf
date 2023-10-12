module "de22" {
    source = "./de22"
    count = 1
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