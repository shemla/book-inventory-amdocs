# In this file:
# user pools
# signup-related functions
# signin related functions
# reset password related functions
# create first user that can invite other users. 


module "aws_cognito_user_pool_complete" {
  source  = "lgallard/cognito-user-pool/aws"
  user_pool_name           = "book_inventory_users"

  alias_attributes         = ["email", "phone_number"]
  auto_verified_attributes = ["email"]

  deletion_protection = "ACTIVE"

  # onboarding experience
  admin_create_user_config = {
    email_subject = "Here, your link to join our book inventory"
  }

  verification_message_template_default_email_option  = "CONFIRM_WITH_LINK"
  verification_message_template_email_message_by_link = "`{##Click Here##}`"

  # password preferences
  password_policy = {
    minimum_length                   = 10
    require_lowercase                = false
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 14
  }


  recovery_mechanisms = [
     {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

# attributes of the user model
  schemas = [
    {
      attribute_data_type      = "Boolean"
      developer_only_attribute = false
      mutable                  = true
      name                     = "available"
      required                 = false
    },
    {
      attribute_data_type      = "Boolean"
      developer_only_attribute = true
      mutable                  = true
      name                     = "registered"
      required                 = false
    }
  ]

  string_schemas = [
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "email"
      required                 = true

      string_attribute_constraints = {
        min_length = 7
        max_length = 25
      }
    },
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "branch"
      required                 = false

      string_attribute_constraints = {
        min_length = 1
        max_length = 50
      }
    },
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "displayName"
      required                 = false

      string_attribute_constraints = {
        min_length = 1
        max_length = 50
      }
    },
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "contactInfo"
      required                 = false

      string_attribute_constraints = {
        min_length = 1
        max_length = 500
      }
    }
  ]
}

# create a client to the user pool so it will be able to integrate with web application
resource "aws_cognito_user_pool_client" "cognito_client" {
  name = "cognito_client_book_inventory"
  generate_secret = true
  
  callback_urls                        = ["https://bookteam.net/callback"]
  default_redirect_uri                 = "https://bookteam.net/callback"
      
  user_pool_id = module.aws_cognito_user_pool_complete.id
}

# The policy that is needed to enable authenticated cognito users assume roles based on their user group
data "aws_iam_policy_document" "group_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = ["${var.aws_region}:${module.aws_cognito_user_pool_complete.id}"] #todo: this line might be wrong
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

# the IAM roles that the users groups will assume
module "sysadmins_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = data.aws_iam_policy_document.group_role.json

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  number_of_custom_role_policy_arns = 1
}

module "managers_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = data.aws_iam_policy_document.group_role.json

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  number_of_custom_role_policy_arns = 1
}


module "employees_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = data.aws_iam_policy_document.group_role.json

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  number_of_custom_role_policy_arns = 1
}


module "users_group_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  custom_role_trust_policy = data.aws_iam_policy_document.group_role.json
}




# user groups
resource "aws_cognito_user_group" "sysadmins" {
  name         = "sysadmins"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "A group of system admins with the maximum permissions of the system"
  precedence   = 1
  role_arn     = module.sysadmins_group_role.iam_role_arn
}

resource "aws_cognito_user_group" "managers" {
  name         = "managers"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "A group of branch managers"
  precedence   = 2
  role_arn     = module.managers_group_role.iam_role_arn
}


resource "aws_cognito_user_group" "employees" {
  name         = "employees"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "A group of simple employees"
  precedence   = 3
  role_arn     = module.employees_group_role.iam_role_arn
}


resource "aws_cognito_user_group" "users" {
  name         = "users"
  user_pool_id = module.aws_cognito_user_pool_complete.id
  description  = "The default users group"
  precedence   = 100
  role_arn     = module.users_group_role.iam_role_arn
}

# create the first cognito user
resource "aws_cognito_user" "cognito_user" {
  user_pool_id = module.aws_cognito_user_pool_complete.id
  username     = "sysadmin_main_user"

  attributes = {
    displayName      = "System Administrator"
    branch           = "0"
    email            = var.response_email
    email_verified   = true
  }
}

# add user to the sysadmins group
resource "aws_cognito_user_in_group" "add_first_sysadmin_user" {
  user_pool_id = module.aws_cognito_user_pool_complete.id
  group_name   = aws_cognito_user_group.sysadmins.name
  username     = aws_cognito_user.cognito_user.username
}
 