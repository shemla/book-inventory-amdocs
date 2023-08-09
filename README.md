# Book Inventory Management System (Amdocs interview)
This is a repository to assess an intermediate developer skill with AWS and Terraform by developing the backend for a serverless book inventory management system. Before starting this step-by-step guidance, clone this repositiry to your local machine.

### Initial AWS prerequisites
##### 1. Before starting you'll need to have the following AWS prerequisites:
- AN AWS account (don't user your root user!)
- AWS CLI installed on your local machine
- An AWS IAM user without access to the console and with an access key that can be used with AWS CLI.
- Save the user access key in AWS secrets manager for future access, you'll need it soon to authenticate Terraform before assuming the role.
- An IAM role that the IAM user can assume. You will need the role arn string soon when you'll build the infrastructure with Terraform

Please note: our AWS details are as follows, but you'll need to replace them with your respective details:
- IAM user arn: `arn:aws:iam::255652631076:user/oriashemla-cli-user`
- IAM role arn: `arn:aws:iam::255652631076:role/infra-as-code-role`
- AWS region: `us-east-1`

##### 2. Create a new policy with these permissions, and attach it to the IAM role:

    permission json
    placeholder

And the following trust policy:

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "Statement1",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::255652631076:user/oriashemla-cli-user"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }

##### 3. Create a new policy with these permissions, and attach it For the IAM user:

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AssumeRole1",
                "Effect": "Allow",
                "Action": ["sts:AssumeRole"],
                "Resource": ["arn:aws:iam::255652631076:role/infra-as-code-role"]
            }
        ]
    }

##### 4. Before moving on, go to AWS Secrets Manager and display the IAM user access key details you saved before. Define your access key on the local machine with the command `aws configure` 

### Initial setup with Terraform
##### 5. First, in order to establish our Terraform backend on AWS and not on our local machine, in the directory named *terraform-config* open the file named *terraform.tf* and make sure the blocks **backend "s3"** and **module "components"** are commented out.

After that, the file *teraform.tf* should look like that:
    
    terraform {
      #backend "s3" {
      #  bucket         = "devops-tf-state-bucket-1232323" # BUCKET NAME
      #  key            = "tfstate"
      #  region         = "us-east-1"
      #  dynamodb_table = "devops-state-locking-table"
      #  encrypt        = true
      #  role_arn       = "arn:aws:iam::255652631076:role/infra-as-code-role"
      #  access_key     = ""
      #  secret_key     = ""
      #}
    
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
    
    #module "components" {
    #  source = "./components"
    #}





##### 6. You're good to start building your infrastructure. Do the following by its order:
- Run the command `terraform init`
- Run the command `terraform apply`
- Type `yes` for it to run
- If you recieved an error with the code **AuthorizationHeaderMalformed**, try running `terraform apply -var="devops_s3_name={new-name}"` and instead of `{new-name}` enter a unique name for the S3 devops bucket.  

##### 7. After the apply has been successful, uncomment the blocks from the *terraform.tf* file.

Now the file should look like that:

    terraform {
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




 
##### 8. Run the command `terraform init -migrate-state`
- Delete the files *terraform.tfstate*, *terraform.tfstate.backup* and *./.terraform/terraform.tfstate* from your repository to prevent it from being a security volnurability
- Run the command `terraform apply`




 That's it! your new AWS infrastructure is all set!


