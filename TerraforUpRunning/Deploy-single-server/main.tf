terraform {
  required_version = ">= 1.0.0, <2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-08bf0e5db5b302e19"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}
