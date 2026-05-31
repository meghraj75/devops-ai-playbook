variable "vpc_name" {
  description = "VPC name"
  type = string
}
variable "cidr_block" {
  description = "VPC CIDR block"
  type = string
}

variable "availability_zone" {
  description = "Availability zone"
  type = list(string)
}

variable "subnet_cidrs" {
  description = "Subnet CIDR blocks"
  type = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name for subnet tagging"
  type = string
} 