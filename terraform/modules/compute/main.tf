# aws_security_group called a resource block and name, vpc_id called arguments
resource "aws_security_group" "this" {
    for_each = var.security_groups
    name   = "${var.full_name}-${each.key}-sg"
    vpc_id = var.vpc_id
    dynamic "ingress" {
      for_each = each.value.ingress
      #now we are iterating over list of objects inside map of objects
      #now we have each.value foot the whole sg config and ingress.value for each ingress rule
      content {
        from_port   = ingress.value.from_port
        to_port     = ingress.value.to_port
        protocol    = ingress.value.protocol
        cidr_blocks = ingress.value.cidr_blocks
}
    }
    dynamic "egress" {
      for_each = length(each.value.egress) > 0 ? each.value.egress : [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      content {
        from_port   = egress.value.from_port
        to_port     = egress.value.to_port
        protocol    = egress.value.protocol
        cidr_blocks = egress.value.cidr_blocks
}
    }

    tags = merge(
      {
       Name = "${var.full_name}-${each.key}-sg"
       Environment = var.environment
       Role = each.key
      },
      each.value.extra_tags
      )
}

data "aws_ami" "this" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${var.full_name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "this" {
  for_each                    = var.instances
  ami                         = data.aws_ami.this.id
  instance_type               = each.value.instance_type
  subnet_id                   = element(var.subnets_groups[each.value.subnet_role], 0)
  vpc_security_group_ids      = [aws_security_group.this[each.value.subnet_role].id]
  iam_instance_profile        = each.value.iam_instance_profile
  key_name                    = aws_key_pair.this.key_name
/*or simply key_name   = "myapp-key" */
user_data = each.value.script_name !=  null ? file("${path.module}/scripts/${each.value.script_name}") : null
  lifecycle {
    create_before_destroy     = true
    ignore_changes            = [ami]
  }

  tags                        = merge( 
  {
  Name: "${var.full_name}-${each.key}"
  Environment = var.environment
  Role = each.value.subnet_role
    },
    each.value.extra_tags
    )
}
