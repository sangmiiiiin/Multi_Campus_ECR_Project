
### VPC 생성 ###
resource "aws_vpc" "vpc" {
    # VPC Cidr : 10.0.0.0/16
    cidr_block = var.cidr_main
    # Route53 구성을 위한 사전 설정
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        # VPC Name: weplat-vpc
        Name = "${var.tag_name}-vpc"
    }
}

### Subnet 생성 (6ea) ###
resource "aws_subnet" "pub_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = length(var.cidr_public)
    availability_zone = "${var.region}${var.ava_zone[count.index]}" 
    cidr_block = var.cidr_public[count.index]
    tags = {
        Name = "${var.tag_name}-subnet-public-${var.no[count.index]}" 
    }
}

resource "aws_subnet" "pri_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = length(var.cidr_private)
    availability_zone = "${var.region}${var.ava_zone[count.index%length(var.ava_zone)]}"
    cidr_block = var.cidr_private[count.index]
    tags = {
        Name = "${var.tag_name}-subnet-private-${var.no[count.index]}" 
    }
}

resource "aws_subnet" "db_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = length(var.cidr_db)
    availability_zone = "${var.region}${var.ava_zone[count.index]}"
    cidr_block = var.cidr_db[count.index]
    tags = {
        Name = "${var.tag_name}-subnet-private-${var.no[count.index+2]}" 
    }
}

### IGW 생성 ###
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.tag_name}-igw"
    }
}

### NAT 생성 ###
resource "aws_eip" "nat_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.pub_subnet[1].id
    tags = {
        Name = "${var.tag_name}-nat"
    }
    
}

### Route Table 생성 및 연결 ###
# Public RT
resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = var.cidr_all
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.tag_name}-pub-rt"
    }
}

resource "aws_route_table_association" "pub_rt_ass" {
  count          = length(var.cidr_public)
  subnet_id      = aws_subnet.pub_subnet[count.index].id
  route_table_id = aws_route_table.pub_rt.id
}

# Private RT
resource "aws_route_table" "pri_rt" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = var.cidr_all
        gateway_id = aws_nat_gateway.natgw.id
    }
    tags = {
        Name = "${var.tag_name}-pri-rt"
    }
}

resource "aws_route_table_association" "pri_rt_ass" {
  count          = length(var.cidr_private)
  subnet_id      = aws_subnet.pri_subnet[count.index].id
  route_table_id = aws_route_table.pri_rt.id
}

# DB RT
resource "aws_route_table" "db_rt" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.tag_name}-db-rt"
    }
}

resource "aws_route_table_association" "db_rt_ass" {
  count          = length(var.cidr_db)
  subnet_id      = aws_subnet.db_subnet[count.index].id
  route_table_id = aws_route_table.db_rt.id
}
