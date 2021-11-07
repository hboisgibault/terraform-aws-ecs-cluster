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

#
# INGRESS SECURITY GROUPS RULES
#

data "aws_security_group" "ingress_sg" {
    count = length(var.ingress_security_groups)
    name = var.ingress_security_groups[count.index]
}

resource "aws_security_group_rule" "local_ingress_traffic" {
    count = length(data.aws_security_group.ingress_sg)
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    source_security_group_id = data.aws_security_group.ingress_sg[count.index].id
    prefix_list_ids = []
    security_group_id = aws_security_group.main_sg.id
}

#
# REMOTE SECURITY GROUPS
#

data "aws_security_group" "remote_sg" {
    count = length(var.remote_ingress_security_groups)
    name = var.remote_ingress_security_groups[count.index]
}

resource "aws_security_group_rule" "remote_ingress_traffic" {
    count = length(data.aws_security_group.remote_sg)
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    source_security_group_id = aws_security_group.main_sg.id
    prefix_list_ids = []
    security_group_id = data.aws_security_group.remote_sg[count.index].id
}