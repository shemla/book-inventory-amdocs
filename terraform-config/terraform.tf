terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THE [backend "s3"] blocks THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  backend "s3" {
    bucket         = "devops-tf-state-bucket-1232323" # BUCKET NAME
    key            = "tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-state-locking-table"
    encrypt        = true
    role_arn       = "arn:aws:iam::255652631076:role/infra-as-code-role"
    access_key     = ""
    secret_key     = ""
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.11.0"
    }
  }
  required_version = ">= 1.5.4"
}
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::255652631076:role/infra-as-code-role"
    session_name = "terraform_session"

  }
}

module "components" {
  source = "./components"
}

