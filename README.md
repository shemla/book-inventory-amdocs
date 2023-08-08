# Book Inventory Management System (Amdocs interview)
This is a repository to assess an intermediate developer skill with AWS and Terraform by developing the backend for a serverless book inventory management system

### Initial AWS prerequisites
Before starting you'll need to have the following AWS prerequisites:
- AN AWS account (don't user your root user!)
- AWS CLI installed on your local machine
- An AWS IAM user without access to the console and with an access key that can be used with AWS CLI.
- Save the user access key in AWS secrets manager for future access
- An IAM role that the IAM user can assume, and has the following permissions:
    permission json
    placeholder

Before moving on, define your access key in the code edittor with the command 

### Initial setup with Terraform
First, in order to assume the role with the permissions to build our infrastructure, and to establish our Terraform backend on AWS and not on our local machine, in the directory named *terraform-config* open the file named *terraform.tf* and make sure the following blocks are commented out:
- backend "s3"
- module "services"

After that, the file *teraform.tf* should look like that:
    
    terraform {
      #backend "s3" {
      #  bucket         = var.devops_s3_name # BUCKET NAME
      #  key            = "./terraform.tfstate"
      #  region         = var.aws_region
      #  dynamodb_table = var.devops_dynamodb_name
      #  encrypt        = true
      #}
      
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 4.49.0"
        }
      }
      required_version = ">= 1.2.0"
    }
    
    provider "aws" {
      region = var.aws_region
      assume_role {
        role_arn = var.role_arn
      }
    }




You're good to set it up. Do the following by its order:
- Run the command 'terraform init'
- Run the command 'terraform apply'
- Type 'yes' for it to run
- If you recieved an error with the code **AuthorizationHeaderMalformed**, try running 'terraform apply -var="devops_s3_name=<new-name>"' and instead of '<new-name>' enter a unique name for the S3 devops bucket.  
- After the apply has been successful, uncomment the blocks from the *terraform.tf* file.

Now the file should look like that:

    terraform {
      #backend "s3" {
      #  bucket         = var.devops_s3_name # BUCKET NAME
      #  key            = "./terraform.tfstate"
      #  region         = var.aws_region
      #  dynamodb_table = var.devops_dynamodb_name
      #  encrypt        = true
      #}
      
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 4.49.0"
        }
      }
      required_version = ">= 1.2.0"
    }
    
    provider "aws" {
      region = var.aws_region
      assume_role {
        role_arn = var.role_arn
      }
    }



 
- Run again the command 'terraform init'
- Delete the file *terraform.tfstate* from your repository to prevent it from being a security volnurability
- Run the command 'terraform apply'


 That's it! your new AWS infrastructure is all set!


