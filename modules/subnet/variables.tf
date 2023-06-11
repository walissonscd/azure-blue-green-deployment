variable "name" {
  description = "Name of the subnet"
  type        = string
}

variable "vnet_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "resource_group_name" {
  type        = string

}

variable "vnet_name" {
  type        = string
}
variable "subnet_prefixes" {
  type = list(string)
}
