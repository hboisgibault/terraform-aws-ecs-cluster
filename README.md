## About

Launch an ECS cluster (EC2 mode) with a load balancer and autoscaling.

This module will create :
- an ECS cluster
- an ECS service with provided task definition
- an autoscaling group with a launch configuration (EC2 instances)
- an ALB listener rule with a custom host and priority to point traffic to the cluster
- a security group for the ECS service
- optional extra security groups

The load balancer is not created but should be provided. It is useful if you have a shared load balancer and want to launch ECS clusters directly linked to it.

## Usage

```
module "ecs" {
  source  = "hboisgibault/ecs-cluster/aws"
  version = "1.2.4"

  vpc_id = "vpc-xxxxxxx"
  ami_id = "ami-0bce8e5f8fd912af2"
  alb_arn = "arn:aws:elasticloadbalancing:eu-west-3:812844235367:loadbalancer/..."
  alb_security_group_id = "sg-02..."
  alb_listener_arn = "arn:aws:elasticloadbalancing:eu-west-3:812844235367:listener/..."
  subnet_ids = ["subnet-xxxxxxx"]
  ingress_security_groups = ["monitoring-cluster"]
  application_name = "my-app-${terraform.workspace}"
  environment_name = terraform.workspace
  application_host = terraform.workspace == "production" ? "www.my-app.com" : "${terraform.workspace}.my-app.com"
  instance_type = terraform.workspace == "production" ? "t3.large" : "t3a.medium"
  target_capacity = terraform.workspace == "production" ? 3 : 1
  container_port = 8000
  alb_listener_rule_priority = terraform.workspace == "production" ? 1 : 100
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | Region where resources will be created | `string` | `eu-west-3` | no |
| vpc_id | VPC ID where resources will be placed | `string` | no | yes |
| application_name | Name of cluster and service | `string` | no | yes |
| environment_name | Environment name that will be used to tag resources | `string` | no | yes |
| application_host | Host name used by the listener rule | `string` | no | yes |
| ami_id | AMI ID used by the EC2 instances | `string` | `ami-098b0a8e497d07ea6` | no |
| instance_type | Instance types | `string` | `t3.micro` | no |
| user_data | Bash commands to be passed to the instance as userdata. Do NOT include a shebang. | `string` | `` | no |
| subnet_ids | Subnets used by the autoscaling group | `list(string)` | `[]` | no |
| use_alb | Whether to use the Application Load Balancer or not | `bool` | `true` | no |
| alb_arn | ALB ARN | `string` | no | yes |
| alb_security_group_id | ALB security group | `string` | no | yes |
| alb_listener_arn | ALB listener ARN | `string` | no | yes |
| alb_listener_rule_priority | Priority that will be used by the listener rule | `int` | `100` | no |
| ingress_security_groups | List of security group names that will be allowed traffic to the instance | `list(string)` | `[]` | no |
| remote_ingress_security_groups | List of security group names to allow ingress traffic from the instance | `list(string)` | `[]` | no |
| target_capacity | Service target capacity | `int` | `1` | no |
| container_name | Docker container name | `string` | `app` | no |
| container_port | Docker container port | `int` | `3000` | no |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| cluster_name | Name of the cluster | `string` |
