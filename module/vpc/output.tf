output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub_subnet" {
  value = aws_subnet.pub_subnet[*].id
}

output "pri_subnet" {
  value = aws_subnet.pri_subnet[*].id
}

output "db_subnet" {
  value = aws_subnet.db_subnet[*].id
}

output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}

output "web_alb_sg" {
  value = aws_security_group.web_alb_sg.id
}

output "was_alb_sg" {
  value = aws_security_group.was_alb_sg.id
}

output "db_sg" {
  value = aws_security_group.db_sg.id
}

output "web_ecs_sg" {
  value = aws_security_group.web_sg.id
}

output "was_ecs_sg" {
  value = aws_security_group.was_sg.id
}