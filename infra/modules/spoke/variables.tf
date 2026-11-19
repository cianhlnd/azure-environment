variable "subnets" {
  description = "Subnet names mapped to their address ranges"
  type        = map(string)
}

variable "resource_group_name" {
  description = "Name of hub Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region for the hub network"
  type        = string
}

variable "address_space" {
  description = "List of different addresses used for and in the hub vnet"
  type        = list(string)
}

variable "vnet_name" {
  description = "Used for naming the vnet"
  type        = string
}

variable "tags" {
  description = "Used for defining tags"
  type        = map(string)
}