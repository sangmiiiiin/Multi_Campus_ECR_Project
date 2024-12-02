#   sg_office_ip      = "211.205.xxx.xxx/32"
#   protocol_tcp      = "tcp"
#   protocol_all      = "-1"
#   port_all          = "0"
#   port_22           = "22"
#   port_80           = "80"
#   port_443          = "443"    
#   port_8080         = "8080"
#   port_8888         = "8888"
#   port_3306         = "3306"
#   port_3000         = "3000"


resource "aws_security_group" "bastion_sg" {
    name = "${var.tag_name}-bastion-sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        cidr_blocks = [var.sg_office_ip]
        from_port = var.port_22
        protocol = var.protocol_tcp
        to_port = var.port_22
    }
    egress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_all
        protocol = var.protocol_all
        to_port = var.port_all
    }
    tags = {
        Name = "${var.tag_name}-bastion-sg"
    }
}

resource "aws_security_group" "web_alb_sg" {
    name = "${var.tag_name}-web-alb-sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_80
        protocol = var.protocol_tcp
        to_port = var.port_80
    }
    ingress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_443
        protocol = var.protocol_tcp
        to_port = var.port_443
    }
    ingress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_3000
        protocol = var.protocol_tcp
        to_port = var.port_3000
    }
    ingress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_8080
        protocol = var.protocol_tcp
        to_port = var.port_8080
    }
    egress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_all
        protocol = var.protocol_all
        to_port = var.port_all
    }
    tags = {
        Name = "${var.tag_name}-web-alb-sg"
    }
}

resource "aws_security_group" "web_sg" {
    name = "${var.tag_name}-web-sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.bastion_sg.id]
        from_port = var.port_22
        protocol = var.protocol_tcp
        to_port = var.port_22
    }
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.web_alb_sg.id]
        from_port = var.port_80
        protocol = var.protocol_tcp
        to_port = var.port_80
    }
    egress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_all
        protocol = var.protocol_all
        to_port = var.port_all
    }
    tags = {
        Name = "${var.tag_name}-web-sg"
    }
}

resource "aws_security_group" "was_alb_sg" {
    name = "${var.tag_name}-was-alb-sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        cidr_blocks = [var.sg_office_ip]
        from_port = var.port_80
        protocol = var.protocol_tcp
        to_port = var.port_80
    }
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.web_sg.id]
        from_port = var.port_80
        protocol = var.protocol_tcp
        to_port = var.port_80
    }
    ingress {
        cidr_blocks = [var.sg_office_ip]
        from_port = var.port_443
        protocol = var.protocol_tcp
        to_port = var.port_443
    }
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.web_sg.id]
        from_port = var.port_443
        protocol = var.protocol_tcp
        to_port = var.port_443
    }
    egress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_all
        protocol = var.protocol_all
        to_port = var.port_all
    }
    tags = {
        Name = "${var.tag_name}-was-alb-sg"
    }
}

resource "aws_security_group" "was_sg" {
    name = "${var.tag_name}-was-sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.was_alb_sg.id]
        from_port = var.port_8080
        protocol = var.protocol_tcp
        to_port = var.port_8080
    }
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.was_alb_sg.id]
        from_port = var.port_8888
        protocol = var.protocol_tcp
        to_port = var.port_8888
    }
    egress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_all
        protocol = var.protocol_all
        to_port = var.port_all
    }
    tags = {
        Name = "${var.tag_name}-was-sg"
    }
}

resource "aws_security_group" "db_sg" {
    name = "${var.tag_name}-db-sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.was_sg.id]
        from_port = var.port_3306
        protocol = var.protocol_tcp
        to_port = var.port_3306
    }
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.bastion_sg.id]
        from_port = var.port_3306
        protocol = var.protocol_tcp
        to_port = var.port_3306
    }
    egress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_all
        protocol = var.protocol_all
        to_port = var.port_all
    }
    tags = {
        Name = "${var.tag_name}-db-sg"
    }
}

resource "aws_security_group" "monitoring_sg" {
    name = "${var.tag_name}-monitoring-sg"
    vpc_id = aws_vpc.vpc.id
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.bastion_sg.id]
        from_port = var.port_22
        protocol = var.protocol_tcp
        to_port = var.port_22
    }
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.web_alb_sg.id]
        from_port = var.port_3000
        protocol = var.protocol_tcp
        to_port = var.port_3000
    }
    ingress {
        cidr_blocks = []
        security_groups = [aws_security_group.web_alb_sg.id]
        from_port = var.port_8080
        protocol = var.protocol_tcp
        to_port = var.port_8080
    }
    egress {
        cidr_blocks = [var.cidr_all]
        from_port = var.port_all
        protocol = var.protocol_all
        to_port = var.port_all
    }
    tags = {
        Name = "${var.tag_name}-monitoring-sg"
    }
}