resource "aws_instance" "nat_instance" {
  ami                         = "ami-03e1b76cba2a101c3"
  instance_type               = "t3.micro"
  key_name                    = "oriel-key"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  source_dest_check           = false

  vpc_security_group_ids = [aws_security_group.nat_sg.id]

  tags = {
    Name = "nat-instance"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "jenkins_master" {
  ami           = var.ami_jenkins_master
  instance_type = "t3.small"
  subnet_id     = aws_subnet.private.id
  key_name      = "oriel-key"

  vpc_security_group_ids = [
    aws_security_group.jenkins_master_sg.id
  ]

  iam_instance_profile = "ec2_jenkins_managment"
  
  tags = {
    Name = "Jenkins Master"
  }
}

resource "aws_instance" "gitlab_sonar" {
  ami           = var.ami_gitlab_sonar
  instance_type = "t3.large"
  subnet_id     = aws_subnet.private.id
  key_name      = "oriel-key"

  vpc_security_group_ids = [
    aws_security_group.gitlab_sonar_sg.id
  ]

  tags = {
    Name = "GitLab & SonarQube"
  }
}
