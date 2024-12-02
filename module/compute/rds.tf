#db subnet group
resource "aws_db_subnet_group" "db-subg" {
    name = "${var.tag_name}-db-subg"
    subnet_ids = var.db_subnet
  
    tags = {
        Name = "${var.tag_name}-db-subg"
  }
}

# db parameter group
resource "aws_db_parameter_group" "db-pg" {
    name = "${var.tag_name}-db-pg"
    family = var.db_pg_family
    description = "${var.tag_name}-db-pg"
}

#db option group
resource "aws_db_option_group" "db-og" {
    name = "${var.tag_name}-db-og"
    option_group_description = "${var.tag_name}-db-og"
    engine_name = var.db_engine
    major_engine_version = var.db_engine_version
}

#db instance
resource "aws_db_instance" "db-instance" {
    identifier = "${var.tag_name}-rds"
    allocated_storage = var.db_allocated_storage
    engine               = var.db_engine
    engine_version       = var.db_engine_version
    instance_class       = var.db_instance_class
    username             = var.db_username
    password             = var.db_password
    parameter_group_name = aws_db_parameter_group.db-pg.name
    option_group_name = aws_db_option_group.db-og.name
    skip_final_snapshot  = true
    multi_az = true
    auto_minor_version_upgrade = false
    publicly_accessible = false
    storage_type = var.db_storage_type
    port = var.db_port
    db_subnet_group_name = aws_db_subnet_group.db-subg.name
    vpc_security_group_ids = [var.db_sg]

    depends_on = [
        aws_db_option_group.db-og, 
        aws_db_parameter_group.db-pg, 
        aws_db_subnet_group.db-subg
    ]
    
}