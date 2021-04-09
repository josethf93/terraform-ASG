resource "aws_instance" "joseth_ec2" {
  count         = var.instance_count
  ami           = var.amiid
  instance_type = "t2.micro"
  #vpc_security_group_ids = [aws_security_group.alb_sg.id]
  #subnet_id              = "subnet-06251d4b"
  key_name               = "tf training"
  vpc_security_group_ids = [aws_security_group.alb_sg.id]
  user_data              = <<-EOF
  #!/bin/bash
  nohup busybox httpd -f -p 8080 &
  EOF
  tags = {
    "Name" = "EPCC ASG EXE EC2 ${var.tags[0]} ${count.index + 1}"
  }
}

output "instancepublicip" {
  value = aws_instance.joseth_ec2[*].public_ip
}

resource "aws_security_group" "alb_sg" {
  name   = "epcc_ASG_EXE"
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
}

resource "aws_launch_configuration" "launchconfig" {
  image_id        = var.amiid
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.alb_sg.id]
  key_name        = "tf training"
  name            = "EPCC ASG EXE"
  user_data       = <<-EOF
  #!/bin/bash
  nohup busybox httpd -f -p 8080 &
  EOF
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.launchconfig.id
  min_size             = 2
  max_size             = 3
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.elb.id]
  availability_zones = data.aws_availability_zones.allazs.names 
}

resource "aws_security_group" "elb_sg" {
  name   = "epcc_ASG_elb_EXE"
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
}

data "aws_availability_zones" "allazs" {

}

resource "aws_elb" "elb" {
  name               = "epcc-asg-elb"
  security_groups    = [aws_security_group.elb_sg.id]
  availability_zones = data.aws_availability_zones.allazs.names
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "8080"
    instance_protocol = "http"
  }
  health_check {
    unhealthy_threshold = 2
    healthy_threshold   = 2

    target   = "HTTP:8080/"
    timeout  = 3
    interval = 30

  }
  tags = {
    Environment = "EPCC test"
  }
}
