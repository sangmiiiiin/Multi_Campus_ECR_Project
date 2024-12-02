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

resource "aws_lb_listener" "web_alb_listener_80" {
    load_balancer_arn = aws_lb.web_alb.arn
    port = var.port_80
    protocol = "HTTP"
    default_action {
        type             = "redirect"

        redirect {
          port = var.port_443
          protocol = "HTTPS"
          status_code = "HTTP_301"
        }
        
    }
}

resource "aws_lb_listener" "web_alb_listener_443" {
    load_balancer_arn = aws_lb.web_alb.arn
    port = var.port_443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = "arn:aws:acm:ap-northeast-2:981638470970:certificate/16042306-a754-4583-9bb1-c4d498e5d59f"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.web_alb_tg.arn
    }
}

resource "aws_lb_listener_rule" "web_alb_listener_443_zabbix_rule" {
  listener_arn = aws_lb_listener.web_alb_listener_443.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.web_alb_tg.arn
        weight = 1
      }

      stickiness {
        enabled  = true
        duration = 600
      }
    }
  }

  condition {
    host_header {
      values = ["zabbix.whitehair.store"]
    }
  }
  
  tags = {
   "Name" = "Zabbix-HTTP" 
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

resource "aws_lb_listener" "app_was_alb_listener" {
    load_balancer_arn = aws_lb.was_alb.arn
    port = var.port_8080
    protocol = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.was_alb_tg_8080.arn
    }
}

resource "aws_lb_listener" "job_was_alb_listener" {
    load_balancer_arn = aws_lb.was_alb.arn
    port = var.port_8888
    protocol = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.was_alb_tg_8888.arn
    }
}