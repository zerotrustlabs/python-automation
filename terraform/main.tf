provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    "tool" = "terrform"
    "dept" = "engineering"
  }
}

data "aws_availability_zones" "available" {
}
resource "aws_subnet" "private_subnet" {
  # for_each = {for k,v in var.subnet_cider: k=>v}
  count                   = length(var.subnet_cider_private)
  vpc_id                  = aws_vpc.this.id
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = var.subnet_cider_private[count.index]
  map_public_ip_on_launch = false
  tags = {
    "region"      = "eu-west-1"
    "tool"        = "terraform"
    "subnet_type" = "private"
  }

}


resource "aws_db_subnet_group" "db" {
  name       = "main"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_subnet" "public_subnet" {
  # for_each = {for k,v in var.subnet_cider: k=>v}
  count                   = length(var.subnet_cider_public)
  vpc_id                  = aws_vpc.this.id
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = var.subnet_cider_public[count.index]
  map_public_ip_on_launch = true
  tags = {
    "region"      = "eu-west-1"
    "tool"        = "terraform"
    "subnet_type" = "public"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "ig_route" {
  vpc_id = aws_vpc.this.id
  tags = {
    "region"      = "eu-west-1"
    "tool"        = "terraform"
    "subnet_type" = "public"
  }

}
resource "aws_route" "ig_route" {
  route_table_id         = aws_route_table.ig_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub" {
  count          = length((var.subnet_cider_public))
  route_table_id = aws_route_table.ig_route.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_security_group" "public" {
  vpc_id = aws_vpc.this.id

  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    to_port     = 8080
    from_port   = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    environment = "dev"
    route       = "public"
  }
}


# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

# }
# resource "aws_instance" "ec2" {
#   count = 2
#   ami           = "ami-0f29c8402f8cce65c"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.public_subnet[count.index].id
#   key_name        = aws_key_pair.deployer.key_name
#   # user_data       = base64encode(file("${path.module}/user_data/deploy.sh"))
#   user_data = base64encode(templatefile("${path.module}/user_data/deploy.sh",{
#     index_html = file("${path.module}/user_data/index.html")
#   }))
#   security_groups = [aws_security_group.public.id]
#   tags = {
#     environment = "dev"
#     route       = "public"
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9PjwY7Gq3fB8pcZvZ4Irs5JizL9BXBCykVhnWQvVr3ay5QmQKmcb5wwEcL7wyFn3COmVR3OBm9TDPva/E0PGYIrldnuugCCj4Nsdnek+/fl4tHqUQ0UVyKEI7lxhyoBBwm3pzfIuio6T1xSaxWgTF5zM6MUHZgoEdL6qS4mAFvJ37hu0TbJfAc4z2RF5Au9JOglClwjRNwGl2Gr27LzKpsmVnfw1idLn1xpmsEsFlJAIif0ifi4XAYvSvzXQvhYTNyh5jwjn+EE8XVPsKbTlkTYq7IbfY1eP1jNMLWdPfBxCW5GipqC+BBVo2RMJaJxGaJ6SUgX28n3lZ5XzNu2U+bRiUk1raYUT6jq98vDj2pNlW0ATMdeLZmZiqKhp9v76Xo/asYy4NjmjJjUkYh9Tkt8lVZQtQW3PRmSsTMLbCQWbhF08hT/X09nsiXFucTR3bv2mmY2BJHzm31tsGJD2OPuoAczQeN6CDH0075S1OOqZHYz1m40m7hyokrEUOjfKedgzIQiLV5p6OoB20yCiwa+J8n9KgIf73h6ltW0ZTeI2pgXvdeYLDEon3JhJh56q2pgVg+6h90ufu53XCu4vUO++ywRrHtExcPtg/YZmXWqJsj/JWli/FuL5FoGpM70ZHX+fLBdU8/FlWUduMEwCaULCatsT0sfM235s5cG4MAw== laborant@docker-01"
}

resource "aws_launch_template" "this" {
  image_id               = "ami-0f29c8402f8cce65c"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.public.id]
  user_data = base64encode(templatefile("${path.module}/user_data/deploy.sh", {
    index_html = file("${path.module}/user_data/index.html")
  }))

  tags = {
    environment = "dev"
    route       = "public"
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = aws_subnet.public_subnet[*].id
  # subnets = aws_subnet
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.tg.arn]
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.this]
}