
#loadbalancer ##########################################################################
resource "aws_lb" "loadbalancer" {
  name               = "jasper-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public-subnet.id, aws_subnet.my_subnet.id]
  security_groups    = [aws_security_group.alb.id]
}

# load balancer listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = 80
  protocol          = "HTTP"
#by default return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type  = "text/plain"
      message_body  = "404: page not found"
      status_code   = 404
    }
  }
}

#target group loadbalancer
resource "aws_lb_target_group" "instance" {
  name            = "jasper-target-group"
  port            = 8080
  protocol        = "HTTP"
  vpc_id          = aws_vpc.my_vpc.id
}
#attaching the loadbalancer to instance
resource "aws_lb_target_group_attachment" "jasper-webtestinstance" {
  target_group_arn    = aws_lb_target_group.instance.arn
  target_id           = aws_instance.webtestinstance.id
  port                = 8080
}
resource "aws_lb_listener_rule" "jasper-webtestinstance" {
  listener_arn        = aws_lb_listener.http.arn
  priority            = 101

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance.arn
      }
}
# security group loadbalander
resource "aws_security_group" "alb" {
  name   = "alb-security-group"
  vpc_id = aws_vpc.my_vpc.id
}

# network rules allowing all http inbound request
resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type                  = "ingress"
  security_group_id     = aws_security_group.alb.id
  from_port             = 80
  to_port               = 80
  protocol              = "tcp"
  cidr_blocks           = ["0.0.0.0/0"]

}

# network rules allowing all outbound request
resource "aws_security_group_rule" "Allow_alb_all" {
  type              ="egress"
  security_group_id = aws_security_group.alb.id
  from_port         =  0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [ "0.0.0.0/0" ]
}
# END loadbalancer ############################################################################


# VM ##########################################################################################
resource "aws_instance" "webtestinstance" {
    ami                         = "ami-0e731c8a588258d0d" #amazon linux 2023 AMI
    instance_type               = "t2.micro"
    user_data                   = file("C:/terraform/files/template/userdata.sh") # install script 
    monitoring                  = true
    subnet_id                   = aws_subnet.my_subnet.id
    iam_instance_profile        = aws_iam_instance_profile.dev-resources-iam-instance-profile.name
    security_groups             =  [aws_security_group.first.id]
    associate_public_ip_address = true
     tags = {
    Name = "WEBserverVM"
  }
}
#Defines the role and assumes policy
resource "aws_iam_role" "dev-resources-iam-role" {
  name = "jasper-ssm-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    stack = "test"
  }
}
# Points to the AmazonSSMManagedInstanceCore role
resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
role       = aws_iam_role.dev-resources-iam-role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "dev-resources-iam-instance-profile" {
  name     = "jasper-ssm-profile"
  role     = aws_iam_role.dev-resources-iam-role.name

}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.my_vpc.id
  service_name       = "com.amazonaws.us-east-1.ssm"
  security_group_ids = [aws_security_group.first.id]
  vpc_endpoint_type  = "Interface"
}
# END VM ##########################################################################################


# mySQL ###########################################################################################
resource "aws_db_instance" "mysql_db" {
  identifier           = "jaspermysqldb"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t2.micro"
  db_name              = "webserverdb"
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.private.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = {
    Name        = "jasper db"
  }
}

#only allowing the instance access
resource "aws_security_group" "db_sg" {
  name          = "db_sg"
  description   = "Security group for RDS MySQL"
  vpc_id        = aws_vpc.my_vpc.id
  ingress {
    from_port   = 3306  # MySQL port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.16.10.0/24"]
}

#all outbound allowed
egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_db_subnet_group" "private" {
  name        = "rdsmain-private"
  description = "Private subnets for mySQL instance"
  subnet_ids  = [aws_subnet.my_subnet.id, aws_subnet.public-subnet.id]
}
resource "aws_connect_instance" "connectvm" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  instance_alias           = aws_instance.webtestinstance.id
  outbound_calls_enabled   = true
}
#END mySQL #########################################################################################