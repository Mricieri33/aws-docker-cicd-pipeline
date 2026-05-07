terraform {
  backend "s3" {
    bucket         = "mricieri-devops-33"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

variable "aws_region" {
  description = "AWS region for the infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "app_ami" {
  description = "AMI used by the EC2 instance."
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "Existing IAM instance profile name attached to the EC2 instance role (for example, the profile for ec2-ecr-role)."
  type        = string
  default     = "app-ec2-profile"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "app_sg" {
  name        = "app-deploy-sg"
  description = "Allow HTTP access to the application instance."

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = var.app_ami
  instance_type          = var.instance_type
  iam_instance_profile   = var.ec2_instance_profile_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "app-ec2"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y git docker unzip
              yum install -y awscli
              cd /tmp
              wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
              unzip terraform_1.6.6_linux_amd64.zip
              mv terraform /usr/local/bin/
              systemctl enable docker
              systemctl start docker
              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent
              usermod -aG docker ec2-user
              EOF
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

output "ec2_public_ip" {
  description = "Public IP of the application instance."
  value       = aws_instance.app.public_ip
}
