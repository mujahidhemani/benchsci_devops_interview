variable "cidrblock" {
  default     = "10.100.0.0/21"
  description = "The CIDR network block to use to create the VPC"
}

variable "ami_id" {
  default = "ami-07c2f42209065b99a"
}