resource "aws_vpc" "this" {
    cidr_block           = var.vpc_cidr_block
    enable_dns_support   = true # allows instances to resolve internet domain names and internal aws services to IPs
    enable_dns_hostnames = true # assigns public DNS hostnames to any instance with public IP addresse
    tags                 = merge(
        {Name = "${var.full_name}-vpc"
        environment = var.environment
    }
    )
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags   = merge(
        {Name: "${var.full_name}-igw"
        Environment = var.environment
        },
        
    )
}

/*resource "aws_eip" "this" {
#it is independent resource, dosn't need depends_on []
    for_each   = aws_subnet_public
    domain     = "vpc"
    tags       = merge(
        {Name: "${var.full_name}-eip-${each.key}"
         Environment = var.environment},
    )
}


resource "aws_nat_gateway" "this" {
    for_each         = aws_subnet_public
    allocation_id    = aws_eip.this[each.key].id
    subnet_id        = each.value.id
    tags             = merge(
        {Name: "${var.full_name}-natgw-${each.key}"
         Environment = var.environment},
    )
}*/


resource "aws_subnet" "public" {
    for_each                = var.public_subnets
    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value.cidr_block
    availability_zone       = each.key
    map_public_ip_on_launch = true # auto-assign public IP to all instances launched in this subnet
    tags                    = merge({
        Name: "${var.full_name}-production-${each.key}"
        Environment = var.environment
    },
        each.value.extra_tags
    )
}

resource "aws_route_table" "public" {
    # one route table to rule all public subnets
    vpc_id   = aws_vpc.this.id
    /*route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.this.id
   }
*/
    tags = merge({
       Name: "${var.full_name}-public-rt"
       Environment = var.environment
       },
    )
}

resource "aws_route" "public_internet_access" {
#using a separate route resource to add/deletes without touching the route table, to work with for_each over multiple destinations later
#in production always use separate route resource
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id # or aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}


resource "aws_subnet" "private" {
    for_each                = var.private_subnets
    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value.cidr_block
    availability_zone       = each.value.availability_zone
    tags                    = merge ({
      Name: "${var.full_name}-private-${each.key}"
      Environment = var.environment
    },
      each.value.extra_tags
    )
}

resource "aws_route_table" "private" {
    for_each = aws_subnet.public
    vpc_id   = aws_vpc.this.id
    /* this inline route is simple and works for one route, if it changes it may cause recreation of the whole route table
     route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.this[each.key].id
   }*/

    tags = merge(
       {Name: "${var.full_name}-${each.key}-private-rt"
       Environment = var.environment},
    )
}
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  #associate that subnet with the route table of the corresponding availability zone
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}



