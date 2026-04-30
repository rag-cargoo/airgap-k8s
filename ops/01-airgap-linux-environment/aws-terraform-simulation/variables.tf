variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "airgap-k8s"
}

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "lab"
}

variable "availability_zone" {
  description = "Single AZ for the lab"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR for bastion"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR for Kubernetes nodes"
  type        = string
}

variable "admin_cidr" {
  description = "Admin source CIDR allowed to access bastion"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for all instances"
  type        = string
}

variable "key_pair_name" {
  description = "Existing AWS key pair name"
  type        = string
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion"
  type        = string
  default     = "t3.small"
}

variable "node_instance_type" {
  description = "EC2 instance type for master and worker"
  type        = string
  default     = "m7i-flex.large"
}
