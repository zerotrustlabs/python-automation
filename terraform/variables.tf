variable "cidr_block" {
  description = " vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cider_private" {
  description = " vpc cidr block"
  type        = list(any)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "subnet_cider_public" {
  description = " vpc cidr block"
  type        = list(any)
  default = [
    "10.0.100.0/24",
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

# variable "index_html" {
#   description = "Index variable value"
#   type = string
  
# }