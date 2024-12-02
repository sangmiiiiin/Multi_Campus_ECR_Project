### Web ALB 생성 ###
resource "aws_lb" "web_alb" {
    name = "${var.tag_name}-web-alb"
    internal = false
    load_balancer_type = var.lb_type_application
    subnets = var.pub_subnet
    security_groups = [var.web_alb_sg]
}

resource "aws_lb_target_group" "web_alb_tg" {
    port = var.port_80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id
    name = "${var.tag_name}-web-alb-tg"
}

resource "aws_lb_listener" "web_alb_listener" {
    load_balancer_arn = aws_lb.web_alb.arn
    port = var.port_80
    protocol = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.web_alb_tg.arn
    }
}

### WAS ALB 생성 ###
resource "aws_lb" "was_alb" {
    name = "${var.tag_name}-was-alb"
    internal = false
    load_balancer_type = var.lb_type_application
    subnets = var.pub_subnet
    security_groups = [var.was_alb_sg]
}

resource "aws_lb_target_group" "was_alb_tg_8080" {
    port = var.port_8080
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id
    name = "${var.tag_name}-was-alb-tg-8080"
}

resource "aws_lb_target_group" "was_alb_tg_8888" {
    port = var.port_8888
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc_id
    name = "${var.tag_name}-was-alb-tg-8888"
}

resource "aws_lb_listener" "was_alb_listener" {
    load_balancer_arn = aws_lb.was_alb.arn
    port = var.port_80
    protocol = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.was_alb_tg_8080.arn
    }
}