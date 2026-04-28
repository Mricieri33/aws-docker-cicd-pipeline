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
  default     = "t2.micro"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app" {
  ami           = var.app_ami
  instance_type = var.instance_type

  user_data = <<-EOF
              #!/bin/bash
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              EOF
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}
