variable "location" {
  type    = string
  default = "uksouth"
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "subnet0_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "address_prefixes_ordered" {
  type        = map(number)
  description = "The size of the subnets"
  default = {
    "a" = 28
    "b" = 26
    "c" = 26
    "d" = 27
    "e" = 25
    "f" = 24
  }
}

variable "log_analytics_workspace_name" {
  type = string
}

variable "address_space" {
    type = string
    default = "10.0.0.0/16"
}
