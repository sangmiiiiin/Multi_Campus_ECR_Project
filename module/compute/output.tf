output "aws_lb_target_group_8888" {
  value = aws_lb_target_group.was_alb_tg_8888.arn
}

output "aws_lb_target_group_8080" {
  value = aws_lb_target_group.was_alb_tg_8080.arn
}

output "aws_lb_target_group_80" {
  value = aws_lb_target_group.web_alb_tg.arn
}