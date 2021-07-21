resource "aws_security_group" "main_sg" {
    name = var.application_name
    description = "Allows traffic from load balancer"
    vpc_id = var.vpc_id

    ingress {
        description = ""
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [var.alb_security_group_id]
        cidr_blocks = []
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        self = false
    }

    egress {
        description = ""
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        prefix_list_ids = []
        security_groups = []
        self = false
    }

    tags = {
      Name = var.application_name
      Environment = var.environment_name
    }
}
