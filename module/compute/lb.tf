### Web ALB 생성 ###
resource "aws_lb" "web_alb" {
  name               = "${var.tag_name}-web-alb"
  internal           = false
  load_balancer_type = var.lb_type_application
  subnets            = var.pub_subnet
  security_groups    = [var.web_alb_sg]
}

resource "aws_lb_target_group" "web_alb_tg" {
  port        = var.port_80
  protocol    = var.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
  name        = "${var.tag_name}-web-alb-tg"
}

resource "aws_lb_listener" "web_alb_listener_80" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = var.port_80
  protocol          = var.protocol
  default_action {
    type = "redirect"

    redirect {
      port        = var.port_443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "web_alb_listener_443" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = var.port_443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_alb_tg.arn
  }
}

# Zabbix Listener
resource "aws_lb_target_group" "web_alb_zabbix_tg" {
  port     = var.port_8080
  protocol = var.protocol
  vpc_id   = var.vpc_id
  name     = "${var.tag_name}-zabbix-tg"
}

resource "aws_lb_target_group_attachment" "web_alb_zabbix_tg_at" {
  target_group_arn = aws_lb_target_group.web_alb_zabbix_tg.arn
  target_id        = aws_instance.Monitoring_ec2.id
}

resource "aws_lb_listener_rule" "web_alb_listener_443_zabbix_rule" {
  listener_arn = aws_lb_listener.web_alb_listener_443.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.web_alb_zabbix_tg.arn
        weight = 1
      }
    }
  }

  condition {
    host_header {
      values = ["zabbix.${var.host_header}"]
    }
  }

  tags = {
    "Name" = "HTTPS-Zabbix"
  }
}

# Grafana Listener
resource "aws_lb_target_group" "web_alb_grafana_tg" {
  port     = var.port_3000
  protocol = var.protocol
  vpc_id   = var.vpc_id
  name     = "${var.tag_name}-grafana-tg"
}

resource "aws_lb_target_group_attachment" "web_alb_grafana_tg_at" {
  target_group_arn = aws_lb_target_group.web_alb_grafana_tg.arn
  target_id        = aws_instance.Monitoring_ec2.id
}


resource "aws_lb_listener_rule" "web_alb_listener_443_grafana_rule" {
  listener_arn = aws_lb_listener.web_alb_listener_443.arn
  priority     = 2

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.web_alb_grafana_tg.arn
        weight = 1
      }
    }
  }

  condition {
    host_header {
      values = ["grafana.${var.host_header}"]
    }
  }

  tags = {
    "Name" = "HTTPS-grafana"
  }
}



### WAS ALB 생성 ###
resource "aws_lb" "was_alb" {
  name               = "${var.tag_name}-was-alb"
  internal           = false
  load_balancer_type = var.lb_type_application
  subnets            = var.pub_subnet
  security_groups    = [var.was_alb_sg]
}

resource "aws_lb_target_group" "was_alb_tg_8080" {
  port        = var.port_8080
  protocol    = var.protocol
  target_type = "ip"
  health_check {
    interval = 60
    timeout  = 59
  }
  vpc_id = var.vpc_id
  name   = "${var.tag_name}-was-alb-tg-8080"
}

resource "aws_lb_target_group" "was_alb_tg_8888" {
  port        = var.port_8888
  protocol    = var.protocol
  target_type = "ip"
  health_check {
    interval = 60
    timeout  = 59
  }
  vpc_id = var.vpc_id
  name   = "${var.tag_name}-was-alb-tg-8888"
}

resource "aws_lb_listener" "was_alb_listener" {
  load_balancer_arn = aws_lb.was_alb.arn
  port              = var.port_80
  protocol          = var.protocol
  default_action {
    type = "redirect"

    redirect {
      port        = var.port_443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }

  }
}

resource "aws_lb_listener" "was_alb_listener_443" {
  load_balancer_arn = aws_lb.was_alb.arn
  port              = var.port_443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_rule" "was_alb_listener_8080_rule" {
  listener_arn = aws_lb_listener.was_alb_listener_443.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.was_alb_tg_8080.arn
        weight = 1
      }
    }
  }

  condition {
    host_header {
      values = ["applicant.${var.host_header}"]
    }
  }

  tags = {
    "Name" = "HTTPS-applicant"
  }
}

resource "aws_lb_listener_rule" "was_alb_listener_8888_rule" {
  listener_arn = aws_lb_listener.was_alb_listener_443.arn
  priority     = 2

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.was_alb_tg_8888.arn
        weight = 1
      }
    }
  }

  condition {
    host_header {
      values = ["jobposting.${var.host_header}"]
    }
  }

  tags = {
    "Name" = "HTTPS-jobposting"
  }
}
