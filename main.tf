terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
      region    = "ap-south-1"
      
                }


module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "172.31.0.0/16"
  public_subnet_cidr  = ["172.31.3.0/24", "172.31.4.0/24"]
  public_azs          = ["ap-south-1a", "ap-south-1b"] 
  private_subnet_cidr = ["172.31.1.0/24", "172.31.2.0/24"]
  private_azs         = ["ap-south-1a", "ap-south-1b"]
 }

 module "alb" {
  source              = "./modules/loadbalancer"
  alb_name            = "TFALB"
  type                = "application"
  sec_group           = [module.vpc.sg]
  subnets             = module.vpc.public_subnet_ids
 }

 module "ec2" {
  source              = "./modules/ec2"
  instance_type       = "t2.medium"
  ami 		      = "ami-0f8ca728008ff5af4"
  instance_count      = 3
  pub_sub_id 	      = module.vpc.public_subnet_ids[0]
  secgrp 	      = [module.vpc.sg]
}
