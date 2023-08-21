# In this file:
# temporary files bucket with a folder for pdf's, a folder for entity images, and a folder for book covers
# big bucket with a folder for pdf's, a folder for entity images, and a folder for book covers
module "s3_bucket_files" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = random_pet.s3_files_bucket_name.id
  acl    = "private"

  versioning = {
    enabled = true
  }
  tags = {
    function=local.tag_function_files
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
}

module "s3_bucket_temp_files" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = random_pet.s3_temp_files_bucket_name.id
  acl    = "private"
  
  tags = {
    function=local.tag_function_files
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
}

# infrastructure to enable auto deploy of the lambda code from the repository
module "s3_lambda_codedeploy" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = random_pet.s3_lambda_codedeploy_name.id
  acl    = "private"
  force_destroy =true
  versioning = {
    enabled = true
  }
  tags = {
    function=local.tag_function_infra
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
}
