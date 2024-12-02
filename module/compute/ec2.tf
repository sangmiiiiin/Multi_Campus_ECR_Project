### Key Pair 생성 ###
# resource "aws_key_pair" "keypair" {
#     public_key = file("./.ssh/weplat-key.pub")
#     key_name = "${var.tag_name}-key"
# }

### Bastion EC2 생성 ###
resource "aws_instance" "bastion_ec2" {
    ami = var.ami_amznlinux2
    instance_type = var.ec2_type_bastion
    key_name = "${var.tag_name}-key"
    availability_zone = "${var.region}${var.ava_zone[1]}"
    subnet_id = var.pub_subnet[1]
    vpc_security_group_ids = [var.bastion_sg]
    associate_public_ip_address = true
    root_block_device {
        volume_size = 8
        volume_type = "gp3"
        delete_on_termination = true
    }
    tags = {
        Name = "${var.tag_name}-Bastion"
    }
}