variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "ami_gitlab_sonar" {
  default = "ami-0bb0af1fad2711aa9"
}

variable "ami_jenkins_master" {
  default = "ami-085a654a2ceb2b30d"
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}