variable "region" {
  type    = string
  default = "eu-west-3"
  description = "AWS region where to launch resources"
}

variable "vpc_id" {
  type    = string
  description = "VPC ID where resources will be placed"
}

variable "application_name" {
    type = string
    description = "Name of the cluster and service"
}

variable "environment_name" {
    type = string
    description = "Environment name that will be used to tag resources"
}

variable "application_host" {
    type = string
    description = "Host name that will be used by the listener rule"
}

variable "ami_id" {
    type = string
    default = "ami-098b0a8e497d07ea6"
    description = "AMI used by EC2 instances"
}

variable "instance_type" {
    type = string
    default = "t3.micro"
    description = "Instance type"
}

variable "user_data" {
    type = string
    default = ""
    description = "Bash commands to be passed to the instance as user data"
}

variable "subnet_ids" {
    type = list(string)
    default = []
    description = "Subnets used by the autoscaling group"
}

variable "use_alb" {
    type = bool
    default = true
    description = "Whether to use a load balancer or not"
}

variable "alb_arn" {
    type = string
    description = "Application load balancer ARN"
}

variable "alb_security_group_id" {
    type = string
    description = "Load balancer security group"
}

variable "alb_listener_arn" {
    type = string
    description = "Load balancer listener"
}

variable "alb_listener_rule_priority" {
    type = number
    default = 100
    description = "Load balancer listener rule priority"
}

variable "ingress_security_groups" {
    type = list(string)
    default = []
    description = "List of security group names that will be allowed traffic to the instance"
}

variable "remote_ingress_security_groups" {
    type = list(string)
    default = []
    description = "List of security group names to allow ingress traffic from the instance"
}

variable "target_capacity" {
    type = number
    default = 1
    description = "Service target capacity"
}

variable "container_name" {
    type = string
    default = "app"
    description = "Docker container name"
}

variable "container_port" {
    type = number
    default = 3000
    description = "Docker container port"
}